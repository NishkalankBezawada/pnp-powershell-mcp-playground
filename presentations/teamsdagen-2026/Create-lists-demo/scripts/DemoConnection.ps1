# Shared connection helper for the demo scripts.
# Dot-source it, then call Connect-DemoTenant.
#
# Reads Create-lists-demo/environment/.env and connects with a certificate.
# Exactly one of PNP_CERT_PATH, PNP_CERT_BASE64 or PNP_CERT_THUMBPRINT must be set —
# ambiguity is an error rather than a guess.

Set-StrictMode -Version Latest

function Import-DemoEnv {
    <#
        Parses the .env into a hashtable. Ignores comments and blank lines, strips
        surrounding quotes, and leaves empty values out entirely so callers can test
        for presence with a simple ContainsKey.
    #>
    [CmdletBinding()]
    param(
        [string] $Path = (Join-Path $PSScriptRoot '..\environment\.env')
    )

    if (-not (Test-Path $Path)) {
        throw "No .env found at $Path. Copy the template and fill it in before running the demo."
    }

    $env = @{}
    foreach ($line in Get-Content -Path $Path) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }

        $split = $trimmed.IndexOf('=')
        if ($split -lt 1) { continue }

        $key   = $trimmed.Substring(0, $split).Trim()
        $value = $trimmed.Substring($split + 1).Trim().Trim('"', "'")

        if ($value -ne '') { $env[$key] = $value }
    }

    return $env
}

function Connect-DemoTenant {
    <#
        Connects to either the demo site or the tenant admin site.

        Tenant-wide cmdlets (Get-PnPTenantSite and friends) need a connection to the
        admin host; PnP will not silently elevate an ordinary site connection. Pass
        -Admin when you need one.
    #>
    [CmdletBinding()]
    param(
        [switch] $Admin,
        [string] $Url
    )

    $envVars = Import-DemoEnv

    foreach ($required in 'PNP_CLIENT_ID', 'PNP_SITE_URL', 'PNP_ADMIN_SITE_URL') {
        if (-not $envVars.ContainsKey($required)) {
            throw "$required is not set in .env."
        }
    }

    $tenant = if ($envVars.ContainsKey('PNP_TENANT')) { $envVars['PNP_TENANT'] }
              elseif ($envVars.ContainsKey('PNP_TENANT_ID')) { $envVars['PNP_TENANT_ID'] }
              else { throw 'Set either PNP_TENANT or PNP_TENANT_ID in .env.' }

    if (-not $Url) {
        $Url = if ($Admin) { $envVars['PNP_ADMIN_SITE_URL'] } else { $envVars['PNP_SITE_URL'] }
    }

    # @() matters: a single match comes back as a scalar string, and under StrictMode
    # that makes .Count throw and [0] return the first character instead of the key.
    $certKeys = @(
        @('PNP_CERT_PATH', 'PNP_CERT_BASE64', 'PNP_CERT_THUMBPRINT') |
            Where-Object { $envVars.ContainsKey($_) }
    )

    if ($certKeys.Count -ne 1) {
        throw ("Set exactly one of PNP_CERT_PATH, PNP_CERT_BASE64 or PNP_CERT_THUMBPRINT " +
               "in .env. Found $($certKeys.Count): $($certKeys -join ', ')")
    }

    $connectArgs = @{
        Url            = $Url
        ClientId       = $envVars['PNP_CLIENT_ID']
        Tenant         = $tenant
        TenantAdminUrl = $envVars['PNP_ADMIN_SITE_URL']
        ErrorAction    = 'Stop'
    }

    switch ($certKeys[0]) {
        'PNP_CERT_THUMBPRINT' {
            $connectArgs['Thumbprint'] = $envVars['PNP_CERT_THUMBPRINT']
        }
        'PNP_CERT_PATH' {
            $certPath = $envVars['PNP_CERT_PATH']
            if (-not [System.IO.Path]::IsPathRooted($certPath)) {
                $certPath = Join-Path (Join-Path $PSScriptRoot '..\..') $certPath
            }
            $connectArgs['CertificatePath'] = $certPath
            if ($envVars.ContainsKey('PNP_CERT_PASSWORD')) {
                $connectArgs['CertificatePassword'] =
                    ConvertTo-SecureString $envVars['PNP_CERT_PASSWORD'] -AsPlainText -Force
            }
        }
        'PNP_CERT_BASE64' {
            $connectArgs['CertificateBase64Encoded'] = $envVars['PNP_CERT_BASE64']
            if ($envVars.ContainsKey('PNP_CERT_PASSWORD')) {
                $connectArgs['CertificatePassword'] =
                    ConvertTo-SecureString $envVars['PNP_CERT_PASSWORD'] -AsPlainText -Force
            }
        }
    }

    Write-Host "Connecting to $Url ..." -ForegroundColor Cyan
    Connect-PnPOnline @connectArgs
    Write-Host "Connected." -ForegroundColor Green

    return $envVars
}
