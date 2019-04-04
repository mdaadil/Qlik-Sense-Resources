# Read me

## QlikSense_ServerNodeStatus.ps1
QlikSense script to fetch service status of all nodes in a multinode environment. The script will work on a single node instance as well.
The script will generate a .log file at the locaiton that you provide with the list of services and its status. 

Windows scheduler can be used to schedule this script to track the services status at a scheduled interval.

## QlikSense_GetPostgresDBConnectionDetails.ps1
QlikSense script to fetch PostgreSQL DB connection details. This script allows you to view the max connections configured for the site and the connections in use and available.
The script will generate a .log file at the locaiton that you provide with the DB connection details.

--