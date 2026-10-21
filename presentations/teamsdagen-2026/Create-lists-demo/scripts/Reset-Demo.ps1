<#
.SYNOPSIS
    Puts the demo site back to its pre-demo state so the provisioning demo can be run again.

.DESCRIPTION
    Removes the three demo lists in reverse dependency order, then the eight site
    columns they used. The three Lookup columns are list-scoped, so they are removed
    with their lists and need no separate handling.

    Term sets are left alone by default — they are slow to recreate and are a
    prerequisite, not demo output. Pass -IncludeTermSets to remove those too.

    Safe to run when nothing exists: every step reports and skips.

.PARAMETER IncludeTermSets
    Also delete the 'PnP Playground' term group and its term sets. You will need to
    re-run Setup-DemoPrereqs.ps1 before the next rehearsal.

.PARAMETER Force
    Skip the confirmation prompt. Use in a rehearsal loop, not on a shared tenant.

.EXAMPLE
    pwsh -File ./Create-lists-demo/scripts/Reset-Demo.ps1

.EXAMPLE
    pwsh -File ./Create-lists-demo/scripts/Reset-Demo.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch] $IncludeTermSets,
    [switch] $Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'DemoConnection.ps1')

# Reverse dependency order: Products points at both of the others, Contacts at Customers.
$Lists = @('Products', 'Contacts', 'Customers')

# Site columns only. The Lookup fields are list-scoped and die with their lists.
$SiteColumns = @(
    'ProductID', 'ProductName',
    'ContactPersonName', 'ContactEmail', 'ContactPhone',
    'CustomerName', 'Country', 'Address'
)

$TermGroupName = 'PnP Playground'

$envVars = Connect-DemoTenant

if (-not $Force) {
    Write-Host ''
    Write-Warning "About to delete from $($envVars['PNP_SITE_URL']):"
    Write-Warning "  lists         : $($Lists -join ', ')"
    Write-Warning "  site columns  : $($SiteColumns -join ', ')"
    if ($IncludeTermSets) {
        Write-Warning "  term group    : $TermGroupName (and every term set in it)"
    }
    Write-Host ''

    $answer = Read-Host 'Type DELETE to continue'
    if ($answer -cne 'DELETE') {
        Write-Host 'Cancelled. Nothing was removed.' -ForegroundColor Yellow
        return
    }
}

# --- Lists --------------------------------------------------------------------

foreach ($list in $Lists) {
    $existing = Get-PnPList -Identity $list -ErrorAction SilentlyContinue
    if (-not $existing) {
        Write-Host "List '$list' not present." -ForegroundColor DarkGray
        continue
    }

    Write-Host "Removing list '$list' ..." -ForegroundColor Cyan
    Remove-PnPList -Identity $list -Force
    Write-Host "  removed." -ForegroundColor Green
}

# --- Site columns -------------------------------------------------------------

foreach ($column in $SiteColumns) {
    $field = Get-PnPField -Identity $column -ErrorAction SilentlyContinue
    if (-not $field) {
        Write-Host "Site column '$column' not present." -ForegroundColor DarkGray
        continue
    }

    Write-Host "Removing site column '$column' ..." -ForegroundColor Cyan
    Remove-PnPField -Identity $column -Force
    Write-Host "  removed." -ForegroundColor Green
}

# --- Term store (opt in) ------------------------------------------------------

if ($IncludeTermSets) {
    $group = Get-PnPTermGroup -Identity $TermGroupName -ErrorAction SilentlyContinue
    if ($group) {
        Write-Host "Removing term group '$TermGroupName' ..." -ForegroundColor Cyan
        Remove-PnPTermGroup -Identity $TermGroupName -Force
        Write-Host "  removed. Re-run Setup-DemoPrereqs.ps1 before the next rehearsal." -ForegroundColor Yellow
    }
    else {
        Write-Host "Term group '$TermGroupName' not present." -ForegroundColor DarkGray
    }
}

Write-Host ''
Write-Host 'Reset complete. The demo can be run again.' -ForegroundColor Green
if (-not $IncludeTermSets) {
    Write-Host "Term sets left in place — taxonomy columns will still resolve." -ForegroundColor DarkGray
}
