# Script to grab all Server 2012 Hyper-V cluster nodes MPIO settings
# to run this script from management VM, it's possible you get this error:
#
# Connecting to remote server failed with the following error message
# The WSMan client cannot process the request. Proxy is not supported under
# HTTP transport.  Change the transport to HTTPS and specify valid proxy information and try again.
#
# if so, remove this registry key:
# Remove-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections\WinHttpSettings -Recurse
#
# This script assumes the nodes are running Windows Server 2012 R2 and may not be compatible with 2016 (untested) because of how Get-MPIOSetting behaves
#
# gerry.larsson@gmail.com / February 2021

# output file path - by default it will append if file exists
$csvPath = ".\Desktop\cluster_nodes_mpio_settings.csv"

# get user credentials
$myCredential = (Get-Credential)

# VMM/cluster target
$vmmServerTarget = "PUT_YOUR_VMM_HOST_HERE"

# grab all clusters
$clusters = (Get-SCVMHostCluster -VMMServer $vmmServerTarget)

foreach ($c in $clusters.Name) {
  # grab all nodes
  $nodes = (Get-ClusterNode -Cluster $c)

  foreach ($n in $nodes.Name) {
    # grab mpio settings from each node
    $mpioSettings = (Invoke-Command -ComputerName $n -Credential $myCredential -ScriptBlock { Get-MPIOSetting | Out-String })
  
    # unfortunately the output from Get-MPIOSetting does not produce accessible attributes, so we need to create them by splitting lines and rows
    $mpioSettingsSplitArray = @{}
    $mpioSettingsSplitArray = $mpioSettings -split '\r\n'

    # populate reportObject with the data
    $reportObject = New-Object psobject -Property @{
      ClusterName               = $c
      NodeName                  = $n
      PathVerificationState     = $mpioSettingsSplitArray[2].Split(':')[1].Trim()
      PathVerificationPeriod    = $mpioSettingsSplitArray[3].Split(':')[1].Trim()
      PDORemovePeriod           = $mpioSettingsSplitArray[4].Split(':')[1].Trim()
      RetryCount                = $mpioSettingsSplitArray[5].Split(':')[1].Trim()
      RetryInterval             = $mpioSettingsSplitArray[6].Split(':')[1].Trim()
      UseCustomPathRecoveryTime = $mpioSettingsSplitArray[7].Split(':')[1].Trim()
      CustomPathRecoveryTime    = $mpioSettingsSplitArray[8].Split(':')[1].Trim()
      DiskTimeoutValue          = $mpioSettingsSplitArray[9].Split(':')[1].Trim()
    }

    # append each cluster report to csv
    $reportObject | Export-Csv -Append -NoTypeInformation -Path $csvPath
  }
}