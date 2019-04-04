#---------------------------------------------
# Script Name: QlikSense Server Node Status Check
# Details: QlikSense script to fetch service status of all nodes in a multinode environment. The same script can be used for a single node instance as well.
# Owner: Aadil Madarveet
# Date: 4th April 2019
#---------------------------------------------

$hdrs = @{}
$hdrs.Add("X-Qlik-Xrfkey","abcdefghijklmnop")
#Provide credentials to be used. User should have rights to perform the QRS calls. Replace the values below with a working account
$hdrs.Add("X-Qlik-User", "UserDirectory=QlikSenseServerName; UserId=QlikSenseAdminAccount")
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where {$_.Subject -like '*QlikClient*'}
$Data = Get-Content C:\ProgramData\Qlik\Sense\Host.cfg
$FQDN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($($Data)))
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; 
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
$response = Invoke-RestMethod -Uri "https://$($FQDN):4242/qrs/servicestatus/full?xrfkey=abcdefghijklmnop" -Method Get -Headers $hdrs -ContentType 'application/json' -Certificate $cert

#Construct Log file location to be stored. Provide shared network path if you need to store the log file in a network drive. ex: \\server\share_name
$logFileName =  "ServiceStatus"+"_$(get-date -Format ddMMyyyy)"+".log"
$logFile = "C:\LogFolder\" + $logFileName

#Constructing the enum lookup table.
#To get the enum mapping, call GET /qrs/about/openapi/main
$serviceNames = @{}
$serviceNames.Add(0,'Repository')
$serviceNames.Add(1,'Proxy')
$serviceNames.Add(2,'Scheduler')
$serviceNames.Add(3,'Engine')
$serviceNames.Add(4,'AppMigration')
$serviceNames.Add(5,'Printing')

$serviceStates = @{}
$serviceStates.Add(0,'Initializing')
$serviceStates.Add(1,'CertificatesNotInstalled')
$serviceStates.Add(2,'Running')
$serviceStates.Add(3,'NoCommunication')
$serviceStates.Add(4,'Disabled')
$serviceStates.Add(5,'Unknown')

for ($i=0;$i -lt $response.Length; $i++) {
    $nodeName = $response[$i].serverNodeConfiguration.name
    $nodeServiceId = $response[$i].serviceType
    $nodeServiceStateId = $response[$i].serviceState
    if($nodeServiceStateId -eq 2 -Or $nodeServiceStateId -eq 4) {
        $log = "$(get-date -Format ddMMyyyy_H:mm:ss)" + " - INFO - " + $nodeName + " - " + $serviceNames[$nodeServiceId] + " service status is " + $serviceStates[$nodeServiceStateId].ToUpper()
        Write-Output $log | Out-File -Filepath $logFile -append
    } else {
        $log = "$(get-date -Format ddMMyyyy_H:mm:ss)" + " - FATAL - " + $nodeName + " - " + $serviceNames[$nodeServiceId] + " service status is " + $serviceStates[$nodeServiceStateId].ToUpper()
        Write-Output $log | Out-File -Filepath $logFile -append
    }
}

#---------------------------------------------
#Credits
#Thanks to https://github.com/levi-turner for the Generic QRS API Powershell script
#---------------------------------------------