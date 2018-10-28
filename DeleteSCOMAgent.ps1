############################################################################## 
#   
#   DeleteSCOMAgent.ps1 
#   Original Script by: David Allen 
#   http://aquilaweb.net/2015/07/06/scom-2012-r2-delete-agent-using-powershell/
#
#   The script below has been updated to allow the fully automated way of the agent's deletion.
#   Modifications by:Stoyan Chalakov
#   Further information on the topic:
#   https://blog.pohn.ch/automating-the-scom-2012-r2-agent-deletion-using-powershell/
#   
#   Also thank you to Daniele Grandini for his contribution:   
#   https://nocentdocent.wordpress.com/2012/11/30/how-to-schedule-the-remove-scomdisabledclassinstance-comdlet/
#    
##############################################################################

Param(
  [string]$ManagementServer,
  [string]$AgentFQDN
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager")

try {
#SCOM Management Group Connection
$MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($ManagementServer) 
$MG = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting) 
$Admin = $MG.Administration

$agentManagedComputerType = [Microsoft.EnterpriseManagement.Administration.AgentManagedComputer]; 
$genericListType = [System.Collections.Generic.List``1] 
$genericList = $genericListType.MakeGenericType($agentManagedComputerType) 
$agentList = new-object $genericList.FullName

#Replace DNSHostName with FQDN of agent to be deleted. 
#ComputerName is a SCOM management server to query 
$agent = Get-SCOMAgent -DNSHostName $AgentFQDN -ComputerName $ManagementServer 
$agentList.Add($agent);

$genericReadOnlyCollectionType = [System.Collections.ObjectModel.ReadOnlyCollection``1] 
$genericReadOnlyCollection = $genericReadOnlyCollectionType.MakeGenericType($agentManagedComputerType) 
$agentReadOnlyCollection = new-object $genericReadOnlyCollection.FullName @(,$agentList);

#Remove objects
$admin.DeleteAgentManagedComputers($agentList)
$MG.EntityObjects.DeleteDisabledObjects()
}
Catch {
    $ErrorMessage = "An error occurred while deleting the SCOM agent."
    Write-Verbose "ErrorMessage: $ErrorMessage"
    Throw $ErrorMessage
}