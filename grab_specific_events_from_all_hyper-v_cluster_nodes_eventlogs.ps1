# Script to grab all nodes from Windows Server 2012 Hyper-V cluster nodes and get events within time range
# By default these eventlog fields are captured: MachineName, TimeCreated, Message, Id
# gerry.larsson@gmail.com / February 2021

# output file path - by default it will append if file exists
$csvPath = ".\Desktop\cluster_node_events.csv"

# VMM/cluster target
$vmmServerTarget = "PUT_YOUR_VMM_HOST_HERE"

# define time range (MM/DD/YYYY)
$starttime = (Get-Date 02/02/2021)
$endtime = (Get-Date 02/04/2021)

# log name
# example: Application, System, Security
$eventLogName = "System"

# source
# example: Microsoft-Windows-FailoverClustering
$eventLogSource = "Microsoft-Windows-FailoverClustering"

# event id
# example: 1177 (quorum manager, cluster shutdown event, logLevel 1)
# example: 5120 (cluster shared volume, csv has entered pause state, logLevel 2)
$eventId = 1177

# level
# example: 1 Critical, 2 Error, 3 Warning, 4 Informational, 5 Verbose
$logLevel = 1

# grab all clusters
$clusters = (Get-SCVMHostCluster -VMMServer $vmmServerTarget)

foreach ($c in $clusters.Name) {
  # grab all nodes from cluster
  $nodes = (Get-ClusterNode -Cluster $c)

  foreach ($n in $nodes.Name) {
    # grab all matching events from node
    $getEvents = (Get-WinEvent -ComputerName $n -FilterHashtable @{
      LogName      = $eventLogName
      StartTime    = $starttime
      EndTime      = $endtime
      ProviderName = $eventLogSource
      ID           = $eventId
      Level        = $logLevel
	} -ErrorAction SilentlyContinue | Select-Object -Property MachineName, TimeCreated, Message, Id)

	foreach ($event in $getEvents) {
	  # populate reportObject for each event found
      $reportObject = New-Object psobject -Property @{
        ClusterName = $c
        NodeName    = $n
        TimeCreated = $event.TimeCreated
	    Id          = $event.Id
	    Message     = $event.Message
      }
	  # append each node report to csv
	  $reportObject | Export-Csv -Append -NoTypeInformation -Path $csvPath
	}
  }
}
