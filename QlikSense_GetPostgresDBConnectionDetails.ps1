#---------------------------------------------
# Script Name: QlikSense script to fetch PostgreSQL DB connection details. This script allows you to view the max connections configured for the site and the connections in use and available.
# Owner: Aadil Madarveet
# Date: 4th April 2019
#---------------------------------------------
#Construct Log file location to be stored. Provide shared network path if you need to store the log file in a network drive. ex: \\server\share_name
$logFileName =  "DatabaseConnectionDetails"+"_$(get-date -Format ddMMyyyy)"+".log"
$logFile = "C:\LogFolder\" + $logFileName

function Get-ODBCData{  
    param(
          [string]$query,
          [string]$dsn
         )

    $conn = New-Object System.Data.Odbc.OdbcConnection
	#Create a DSN for the postgresql db under system DSN and provide that name here. Download the postgresql ODBC connector from the postgresql site. https://www.postgresql.org/ftp/odbc/versions/msi/
    $conn.ConnectionString = "DSN=POSTGRESQL_ODBC_DSN_NAME;"	
    $conn.open()
    $command = New-object System.Data.Odbc.OdbcCommand($query,$conn)
    $dataset = New-Object system.Data.DataSet
    (New-Object system.Data.odbc.odbcDataAdapter($command)).fill($dataset) | out-null
    $dataset.Tables[0]
    $conn.close()
}

$result = Get-ODBCData -query "select max_conn,used,res_for_super,max_conn-used-res_for_super res_for_normal from 
  (select count(*) used from pg_stat_activity) t1,
  (select setting::int res_for_super from pg_settings where name='superuser_reserved_connections') t2,
  (select setting::int max_conn from pg_settings where name='max_connections') t3;"

$log = "$(get-date -Format ddMMyyyy_H:mm:ss)" + " - INFO - " + "Max Connections" + " - " + $result.max_conn
Write-Output $log | Out-File -Filepath $logFile -append
$log = "$(get-date -Format ddMMyyyy_H:mm:ss)" + " - INFO - " + "Used" + " - " + $result.used
Write-Output $log | Out-File -Filepath $logFile -append
$log = "$(get-date -Format ddMMyyyy_H:mm:ss)" + " - INFO - " + "Reserved for super" + " - " + $result.res_for_super
Write-Output $log | Out-File -Filepath $logFile -append
$log = "$(get-date -Format ddMMyyyy_H:mm:ss)" + " - INFO - " + "Reserved for normal" + " - " + $result.res_for_normal
Write-Output $log | Out-File -Filepath $logFile -append