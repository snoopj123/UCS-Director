Import-Module CiscoUcsCentralPs

$ucsc_gsp = ($args[0].Split(";"))[2]   # UCS Director variable that contains the DN of the global service profile (GSP)

$ucsc_username = "<insert UCS Central username>"
$ucsc_password = ConvertTo-SecureString -String "<insert UCS Central password for above username>" -AsPlainText -Force
$ucsc_credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ucsc_username, $ucsc_password
$ucsc_conn = Connect-UcsCentral -Name <Insert UCS Central FQDN/IP address> -Credential $ucsc_credential

$cmd_1 = Get-UcsCentralServiceProfile -Dn $ucsc_gsp | Remove-UcsCentralServiceProfile -Force   # Force remove the GSP from UCS Central

Disconnect-UcsCentral -UcsCentral $ucsc_conn   # Disconnect from UCS Central