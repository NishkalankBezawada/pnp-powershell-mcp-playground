<#
.SYNOPSIS
    Finds where one or more Entra ID groups are used in the Microsoft 365 tenant.

.DESCRIPTION
    For every group (given by display name or object ID) the script reports:
      - Group details (type, visibility, mail)
      - Connected SharePoint site
      - Whether the group is a Team, and its channels
      - Owners and members
      - Groups it is a member of (transitive / nested)
      - Enterprise application (service principal) app role assignments

    Connection settings come from environment/.env via DemoConnection.ps1.
    If a PnP connection already exists in the session it is reused.

    Required Graph application permissions on the app registration:
      Group.Read.All, Team.ReadBasic.All, Channel.ReadBasic.All (for channels),
      Sites.Read.All, Application.Read.All (to resolve app role names).

.PARAMETER Group
    One or more group display names or object IDs. A display name that matches
    several groups returns all of them.

.PARAMETER OutCsv
    Optional path to export the usage rows as CSV (UTF-8).

.PARAMETER ForceConnect
    Reconnect to the tenant admin site even if a connection already exists.

.EXAMPLE
    .\Find-EntraGroupUsage.ps1 -Group 'Webinar-Demo','32967d9d-d15f-4d4e-be53-abbd7888b6cb'

.EXAMPLE
    .\Find-EntraGroupUsage.ps1 -Group 'Contoso Team' -OutCsv .\group-usage.csv
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string[]] $Group,

    [string] $OutCsv,

    [switch] $ForceConnect
)

begin {
    . (Join-Path $PSScriptRoot 'DemoConnection.ps1')

    $connected = $false
    if (-not $ForceConnect) {
        try { $null = Get-PnPConnection -ErrorAction Stop; $connected = $true } catch { }
    }
    if (-not $connected) { $null = Connect-DemoTenant -Admin }

    # StrictMode-safe property read for Graph responses.
    function Get-Prop($obj, [string] $name) {
        if ($null -eq $obj) { return $null }
        if ($obj -is [System.Collections.IDictionary]) { return $obj[$name] }
        $p = $obj.PSObject.Properties[$name]
        if ($p) { return $p.Value }
        return $null
    }

    function Invoke-Graph([string] $Url) {
        Invoke-PnPGraphMethod -Url $Url -Method Get -ErrorAction Stop
    }

    # Follows @odata.nextLink and returns every item in 'value'.
    function Invoke-GraphAll([string] $Url) {
        $items = [System.Collections.Generic.List[object]]::new()
        $next = $Url
        while ($next) {
            $r = Invoke-Graph $next
            foreach ($i in @(Get-Prop $r 'value')) { if ($null -ne $i) { $items.Add($i) } }
            $next = Get-Prop $r '@odata.nextLink'
        }
        $items.ToArray()
    }

    function Get-ErrorText($err) { ($err.Exception.Message -split "`n")[0].Trim() }

    $guidPattern = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    $select = 'id,displayName,mail,visibility,groupTypes,securityEnabled,resourceProvisioningOptions'
    $appRoleCache = @{}
    $results = [System.Collections.Generic.List[object]]::new()

    function Add-Row($grp, [string] $usage, [string] $target, [string] $detail) {
        $results.Add([pscustomobject]@{
            GroupName = Get-Prop $grp 'displayName'
            GroupId   = Get-Prop $grp 'id'
            UsageType = $usage
            Target    = $target
            Detail    = $detail
        })
    }

    function Resolve-AppRoleName([string] $resourceId, [string] $appRoleId) {
        if ($appRoleId -eq '00000000-0000-0000-0000-000000000000') { return 'Default Access' }
        if (-not $appRoleCache.ContainsKey($resourceId)) {
            try { $appRoleCache[$resourceId] = @(Get-Prop (Invoke-Graph "v1.0/servicePrincipals/$resourceId`?`$select=appRoles") 'appRoles') }
            catch { $appRoleCache[$resourceId] = @() }
        }
        $role = $appRoleCache[$resourceId] | Where-Object { (Get-Prop $_ 'id') -eq $appRoleId } | Select-Object -First 1
        if ($role) { return Get-Prop $role 'displayName' }
        return $appRoleId
    }
}

process {
    foreach ($g in $Group) {
        # Resolve name or ID to group objects
        $groups = @()
        try {
            if ($g -match $guidPattern) {
                $groups = @(Invoke-Graph "v1.0/groups/$g`?`$select=$select")
            } else {
                $filter = [uri]::EscapeDataString("displayName eq '$($g.Replace("'", "''"))'")
                $groups = @(Invoke-GraphAll "v1.0/groups?`$filter=$filter&`$select=$select")
            }
        } catch {
            Write-Warning "Could not resolve '$g': $(Get-ErrorText $_)"
            continue
        }
        if ($groups.Count -eq 0) { Write-Warning "No group found for '$g'."; continue }
        if ($groups.Count -gt 1) { Write-Warning "'$g' matches $($groups.Count) groups; reporting all of them." }

        foreach ($grp in $groups) {
            $id   = Get-Prop $grp 'id'
            $name = Get-Prop $grp 'displayName'
            Write-Host "Scanning $name [$id] ..." -ForegroundColor Cyan

            $type = if (@(Get-Prop $grp 'groupTypes') -contains 'Unified') { 'Microsoft 365' }
                    elseif (Get-Prop $grp 'securityEnabled') { 'Security' } else { 'Distribution' }
            Add-Row $grp 'Group' $name "Type=$type; Visibility=$(Get-Prop $grp 'visibility'); Mail=$(Get-Prop $grp 'mail')"

            # Connected SharePoint site (M365 groups only)
            if ($type -eq 'Microsoft 365') {
                try { Add-Row $grp 'SharePointSite' (Get-Prop (Invoke-Graph "v1.0/groups/$id/sites/root?`$select=webUrl") 'webUrl') 'Group-connected site' }
                catch { Add-Row $grp 'SharePointSite' '' "Error: $(Get-ErrorText $_)" }
            }

            # Team + channels
            try {
                $null = Invoke-Graph "v1.0/teams/$id`?`$select=id"
                Add-Row $grp 'Team' $name 'Group is Teams-enabled'
                try {
                    foreach ($c in Invoke-GraphAll "v1.0/teams/$id/allChannels?`$select=displayName,membershipType") {
                        Add-Row $grp 'TeamChannel' (Get-Prop $c 'displayName') "MembershipType=$(Get-Prop $c 'membershipType')"
                    }
                } catch { Add-Row $grp 'TeamChannel' '' "Error: $(Get-ErrorText $_)" }
            } catch {
                if ((Get-ErrorText $_) -notmatch 'No team found|NotFound|404') { Add-Row $grp 'Team' '' "Error: $(Get-ErrorText $_)" }
            }

            # Owners and members
            foreach ($rel in 'owners', 'members') {
                try {
                    $list = @(Invoke-GraphAll "v1.0/groups/$id/$rel`?`$select=id,displayName,userPrincipalName")
                    $usage = if ($rel -eq 'owners') { 'Owner' } else { 'Member' }
                    foreach ($m in $list) {
                        $kind = (Get-Prop $m '@odata.type') -replace '#microsoft.graph.', ''
                        $who  = Get-Prop $m 'userPrincipalName'; if (-not $who) { $who = Get-Prop $m 'displayName' }
                        Add-Row $grp $usage $who "ObjectType=$kind"
                    }
                    if ($list.Count -eq 0) { Add-Row $grp $usage '' "No $rel" }
                } catch { Add-Row $grp $rel '' "Error: $(Get-ErrorText $_)" }
            }

            # Nested membership: groups / roles this group belongs to
            try {
                foreach ($p in Invoke-GraphAll "v1.0/groups/$id/transitiveMemberOf?`$select=id,displayName") {
                    $kind = (Get-Prop $p '@odata.type') -replace '#microsoft.graph.', ''
                    Add-Row $grp 'MemberOf' (Get-Prop $p 'displayName') "ObjectType=$kind; Id=$(Get-Prop $p 'id')"
                }
            } catch { Add-Row $grp 'MemberOf' '' "Error: $(Get-ErrorText $_)" }

            # Enterprise app role assignments
            try {
                foreach ($a in Invoke-GraphAll "v1.0/groups/$id/appRoleAssignments") {
                    $role = Resolve-AppRoleName (Get-Prop $a 'resourceId') (Get-Prop $a 'appRoleId')
                    Add-Row $grp 'AppRoleAssignment' (Get-Prop $a 'resourceDisplayName') "Role=$role"
                }
            } catch { Add-Row $grp 'AppRoleAssignment' '' "Error: $(Get-ErrorText $_)" }
        }
    }
}

end {
    $results | Format-Table GroupName, UsageType, Target, Detail -AutoSize -Wrap | Out-Host

    # Summary of where each group is actually used beyond its own owners/members
    $usageTypes = 'SharePointSite', 'Team', 'TeamChannel', 'MemberOf', 'AppRoleAssignment'
    $results | Group-Object GroupId | ForEach-Object {
        $rows = $_.Group
        $used = @($rows | Where-Object { $_.UsageType -in $usageTypes -and $_.Target -and $_.Detail -notlike 'Error:*' })
        Write-Host ("{0}: {1}" -f $rows[0].GroupName, $(if ($used.Count) { ($used | ForEach-Object { "$($_.UsageType) -> $($_.Target)" }) -join '; ' } else { 'no usage found' })) -ForegroundColor Yellow
    }

    if ($OutCsv) {
        $results | Export-Csv -Path $OutCsv -NoTypeInformation -Encoding utf8
        Write-Host "Exported $($results.Count) rows to $OutCsv" -ForegroundColor Green
    }
}
