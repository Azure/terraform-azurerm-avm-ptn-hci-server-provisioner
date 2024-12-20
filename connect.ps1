param(
    $userName,
    $password,
    $authType,
    $ip, $port,
    $subscriptionId, $resourceGroupName, $region, $tenant, $servicePrincipalId, $servicePrincipalSecret, $expandC
)

$script:ErrorActionPreference = 'Stop'
echo "Start to connect Arc server!"
$count = 0
$retryCount = 3

if ($authType -eq "CredSSP") {
    try {
        echo "set trusted hosts"
        Set-Item wsman:localhost\client\trustedhosts -value * -Force
        echo "enable client CredSSP"
        Enable-WSManCredSSP -Role Client -DelegateComputer * -Force

        echo "Allow fresh credentials"
        $key = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
        if (!(Test-Path $key)) {
            md $key
        }
        New-ItemProperty -Path $key -Name AllowFreshCredentials -Value 1 -PropertyType Dword -Force            

        $allowFreshCredentialsKey = Join-Path $key 'AllowFreshCredentials'
        if (!(Test-Path $allowFreshCredentialsKey)) {
            md $allowFreshCredentialsKey
        }

        if (!(Get-ItemProperty -Path $allowFreshCredentialsKey -Name 'AzureArcIaCAutomation' -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $allowFreshCredentialsKey -Name 'AzureArcIaCAutomation' -Value 'WSMAN/*' -PropertyType String -Force
        }

        echo "Allow fresh credentials when NTLM only"
        New-ItemProperty -Path $key -Name AllowFreshCredentialsWhenNTLMOnly -Value 1 -PropertyType Dword -Force

        $allowFreshCredentialsWhenNTLMOnlyKey = Join-Path $key 'AllowFreshCredentialsWhenNTLMOnly'
        if (!(Test-Path $allowFreshCredentialsWhenNTLMOnlyKey)) {
            md $allowFreshCredentialsWhenNTLMOnlyKey
        }

        if (!(Get-ItemProperty -Path $allowFreshCredentialsWhenNTLMOnlyKey -Name 1 -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $allowFreshCredentialsWhenNTLMOnlyKey -Name 1 -Value 'WSMAN/*' -PropertyType String -Force
        }
    }
    catch {
        echo "Enable-WSManCredSSP failed: $_"
    }
}
for ($count = 0; $count -lt $retryCount; $count++) {
    try {
        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ".\$username", $secpasswd
        $session = New-PSSession -ComputerName $ip -Port $port -Authentication $authType -Credential $cred

        Invoke-Command -Session $session -ScriptBlock {
            Param ($subscriptionId, $resourceGroupName, $region, $tenant, $servicePrincipalId, $servicePrincipalSecret)
            $script:ErrorActionPreference = 'Stop'

            function Install-ModuleIfMissing {
                param(
                    [Parameter(Mandatory = $true)]
                    [string]$Name,
                    [string]$Repository = 'PSGallery',
                    [switch]$Force,
                    [switch]$AllowClobber
                )
                $script:ErrorActionPreference = 'Stop'
                $module = Get-Module -Name $Name -ListAvailable
                if (!$module) {
                    Write-Host "Installing module $Name"
                    Install-Module -Name $Name -Repository $Repository -Force:$Force -AllowClobber:$AllowClobber
                }
            }

            if ($expandC) {
                # Expand C volume as much as possible
                $drive_letter = "C"
                $size = (Get-PartitionSupportedSize -DriveLetter $drive_letter)
                if ($size.SizeMax -gt (Get-Partition -DriveLetter $drive_letter).Size) {
                    echo "Resizing volume"
                    Resize-Partition -DriveLetter $drive_letter -Size $size.SizeMax
                }
            }

            echo "Validate BITS is working"
            $job = Start-BitsTransfer -Source https://aka.ms -Destination $env:TEMP -TransferType Download -Asynchronous
            $bitsRetry = 0
            while ($job.JobState -ne "Transferred" -and $bitsRetry -lt 30) {
                if ($job.JobState -eq "TransientError") {
                    throw "BITS transfer failed"
                }
                sleep 6
                $bitsRetry++
            }
            if ($bitsRetry -ge 30) {
                throw "BITS transfer failed after 3 minutes. Job state: $job.JobState"
            }

            echo "Install modules"
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
            Install-ModuleIfMissing -Name Az -Repository PSGallery -Force
            Install-ModuleIfMissing Az.Accounts -Force -AllowClobber
            Install-ModuleIfMissing Az.ConnectedMachine -Force -AllowClobber
            Install-ModuleIfMissing Az.Resources -Force -AllowClobber

            echo "login to Azure"
            $creds = [System.Management.Automation.PSCredential]::new($servicePrincipalId, (ConvertTo-SecureString $servicePrincipalSecret -AsPlainText -Force))
            Connect-AzAccount -Subscription $subscriptionId -Tenant $tenant -Credential $creds -ServicePrincipal
            $tenantId = (Get-AzContext).Tenant.Id
            $token = (Get-AzAccessToken).Token

            $machineName = [System.Net.Dns]::GetHostName()
            $correlationID = New-Guid
            $azcmagentPath = "$env:ProgramW6432\AzureConnectedMachineAgent\azcmagent.exe"
            if (!(Test-Path $azcmagentPath)) {
                wget -Uri "https://aka.ms/AzureConnectedMachineAgent" -OutFile "$env:TEMP\AzureConnectedMachineAgent.msi"
                msiexec /i "$env:TEMP\AzureConnectedMachineAgent.msi" /l*v "$env:TEMP\AzureConnectedMachineAgentInstall.log" /qn
            }
            & "$azcmagentPath" connect --resource-group "$resourceGroupName" --resource-name "$machineName" --tenant-id "$tenantId" --location "$region" --subscription-id "$subscriptionId" --cloud "AzureCloud" --correlation-id "$correlationID" --access-token "$token";
            $exitCode = $LASTEXITCODE
            if ($exitCode -eq 0) {
                echo "Arc server connected!"
            }
            else {
                throw "Arc server connection failed"
            }

            echo "PUT edge device resource to install mandatory extensions"
            $uri = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.HybridCompute/machines/$machineName/providers/Microsoft.AzureStackHCI/edgeDevices/default?api-version=2024-04-01"
            $body = @{
                "kind" = "HCI";
                "properties" = @{};
            }
            $headers = @{
                "Authorization" = "Bearer $token";
            }
            Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body ($body | ConvertTo-Json) -ContentType "application/json"

            echo "Waiting for Edge device resource to be ready"
            sleep 600
            $waitCount = 0
            $waitLimit = 60
            $ready = $false
            while (!$ready -and $waitCount -lt $waitLimit) {
                Connect-AzAccount -Subscription $subscriptionId -Tenant $tenant -Credential $creds -ServicePrincipal | Out-Null
                $token = (Get-AzAccessToken).Token
                $headers = @{
                    "Authorization" = "Bearer $token";
                }
                try {
                    $resp = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
                    if ($resp.properties.provisioningState -eq "Succeeded") {
                        $ready = $true
                    }
                } catch {
                    echo "Failed to get Edge device resource: $_"
                } finally {
                    echo "Waiting for Edge device resource to be ready"
                    $waitCount++
                    Start-Sleep -Seconds 30
                }
            }
            if ($waitCount -ge $waitLimit) {
                throw "Edge device resource is not ready after 30 minutes."
            }
        } -ArgumentList $subscriptionId, $resourceGroupName, $region, $tenant, $servicePrincipalId, $servicePrincipalSecret

        echo "Arc server connected and all mandatory extensions are ready!"
        break
    }
    catch {
        echo "Error in retry ${count}:`n$_"
    }
    finally {
        if ($session) {
            Remove-PSSession -Session $session
        }
    }
}

if ($count -ge $retryCount) {
    echo "Failed to connect Arc server after $retryCount retries."
    throw "Arc server connection failed"
}
