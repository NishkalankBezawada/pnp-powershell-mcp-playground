<#
.SYNOPSIS
    Creates the managed metadata the list definitions bind to.

.DESCRIPTION
    The Taxonomy columns in customers.json and products.json bind to term sets BY NAME.
    If the term group and term sets do not exist in the default term store, those fields
    fail to resolve and the provisioning demo dies on stage.

    Run this once before the session. It is idempotent — run it again and it reports
    what already exists instead of failing.

.EXAMPLE
    pwsh -File ./Create-lists-demo/scripts/Setup-DemoPrereqs.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'DemoConnection.ps1')

$TermGroupName = 'PnP Playground'

# Sample terms exist so the demo's taxonomy pickers are not empty when someone opens
# a list to check the result. Keep them short — they show up on a projector.
$TermSets = [ordered]@{
    'Countries'           = @('Sweden', 'Norway', 'Denmark', 'Finland', 'Germany', 'Netherlands', 'United Kingdom')
    'Product Identifiers' = @('PRD-1001', 'PRD-1002', 'PRD-1003', 'PRD-2001', 'PRD-2002')
    'Product Names'       = @('Aurora Platform', 'Borealis Gateway', 'Cirrus Connector', 'Delta Analytics')
}

Connect-DemoTenant | Out-Null

# --- Term group ---------------------------------------------------------------

$group = Get-PnPTermGroup -Identity $TermGroupName -ErrorAction SilentlyContinue
if ($group) {
    Write-Host "Term group '$TermGroupName' already exists." -ForegroundColor DarkGray
}
else {
    Write-Host "Creating term group '$TermGroupName' ..." -ForegroundColor Cyan
    $group = New-PnPTermGroup -Name $TermGroupName
    Write-Host "  created." -ForegroundColor Green
}

# --- Term sets and terms ------------------------------------------------------

foreach ($setName in $TermSets.Keys) {

    $set = Get-PnPTermSet -TermGroup $TermGroupName -Identity $setName -ErrorAction SilentlyContinue
    if ($set) {
        Write-Host "Term set '$setName' already exists." -ForegroundColor DarkGray
    }
    else {
        Write-Host "Creating term set '$setName' ..." -ForegroundColor Cyan
        $set = New-PnPTermSet -Name $setName -TermGroup $TermGroupName
        Write-Host "  created." -ForegroundColor Green
    }

    $existing = @(Get-PnPTerm -TermGroup $TermGroupName -TermSet $setName -ErrorAction SilentlyContinue |
                  Select-Object -ExpandProperty Name)

    foreach ($term in $TermSets[$setName]) {
        if ($existing -contains $term) {
            Write-Host "  term '$term' already exists." -ForegroundColor DarkGray
            continue
        }

        New-PnPTerm -Name $term -TermSet $setName -TermGroup $TermGroupName | Out-Null
        Write-Host "  added term '$term'." -ForegroundColor Green
    }
}

Write-Host ''
Write-Host 'Prerequisites ready. The taxonomy columns will now resolve.' -ForegroundColor Green
Write-Host "Term group: $TermGroupName" -ForegroundColor Green
Write-Host "Term sets:  $($TermSets.Keys -join ', ')" -ForegroundColor Green
