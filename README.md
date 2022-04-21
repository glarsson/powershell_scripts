A collection of PowerShell scripts I've written:

## grab_mpio_settings_from_all_hyper-v_cluster_nodes.ps1
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
