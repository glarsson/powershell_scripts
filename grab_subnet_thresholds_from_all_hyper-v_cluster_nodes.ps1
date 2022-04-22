# Script to grab all Windows Server 2012 Hyper-V clusters subnet thresholds
# gerry.larsson@gmail.com / February 2021

# output file path - by default it will append if file exists
$csvPath = ".\Desktop\cluster_subnet_thresholds.csv"

# VMM/cluster target
$vmmServerTarget = "PUT_YOUR_VMM_HOST_HERE"

# grab all clusters
$clusters = (Get-SCVMHostCluster -VMMServer $vmmServerTarget)

foreach ($c in $clusters.Name) {
  # grab subnet parameters from each cluster
  $clusterSubnetParameters = (Get-Cluster $c | Select-Object *subnet*)
  # populate reportObject with the data
  $reportObject = New-Object psobject -Property @{
    ClusterName               = $c
    CrossSubnetDelay          = $clusterSubnetParameters.CrossSubnetDelay
    CrossSubnetThreshold      = $clusterSubnetParameters.CrossSubnetThreshold
    PlumbAllCrossSubnetRoutes = $clusterSubnetParameters.PlumbAllCrossSubnetRoutes
    SameSubnetDelay           = $clusterSubnetParameters.SameSubnetDelay
    SameSubnetThreshold       = $clusterSubnetParameters.SameSubnetThreshold        
  }
  # append each cluster report to csv
  $reportObject | Export-Csv -Append -NoTypeInformation -Path $csvPath
}