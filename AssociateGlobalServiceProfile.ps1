Import-Module CiscoUcsCentralPs

# Examples of how the UCS Director variables actually look, as strings

#$ucsd_service_profile = "1;org-root/org-0000000-LE;org-root/org-0000000-LE/ls-JonWinTest1"
#$ucsd_ucsc_server = "1;compute/sys-1015/chassis-1/blade-6"

$ucsc_sp = ($args[0].Split(";"))[2] # UCS Director object for the Service Profile
$ucsc_server = ($args[1].Split(";"))[1] # UCS Director object for the UCS device

$ucsc_username = "INSERT USERNAME"
$ucsc_password = ConvertTo-SecureString -String "" -AsPlainText -Force
$ucsc_credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ucsc_username, $ucsc_password
$ucsc_conn = Connect-UcsCentral -Name -Credential $ucsc_credential

if ($ucsc_server -match "rack-unit-") # UCS device is a C-Series
{
$command_1 = Connect-UcsCentralServiceProfile -ServiceProfile (Get-UcsCentralServiceProfile -Dn $ucsc_sp) -RackUnit (Get-UcsCentralRackUnit -Dn $ucsc_server) -Force
}
else # UCS device is a B-Series
{
$command_1 = Connect-UcsCentralServiceProfile -ServiceProfile (Get-UcsCentralServiceProfile -Dn $ucsc_sp) -Blade (Get-UcsCentralBlade -Dn $ucsc_server) -Force
}

# Wait for the service profile to be completely associated with the hardware AND in either a Powered On or Powered Off state
do {Start-Sleep 10;$sp = Get-UcsCentralServiceProfile -Dn $ucsc_sp} while ($sp.AssocState -ne "associated" -and (($sp.OperState -ne "ok") -or ($sp.OperState -ne "power-off")))

# Determines which UCS domain in UCS Central the physical device is located
$ucs_instance = (Get-UcsCentralComputeInstance -PhysDn (Get-UcsCentralServiceProfile -Dn $ucsc_sp).PnDn).SystemName

# Disconnect from UCS Central
Disconnect-UcsCentral -UcsCentral $ucsc_conn

# Craft a return string for use in UCS Director as a variable for future tasks in the workflow - In this case, the UCS (not UCS Central) Service Profile, so it can be assigned to a UCS Director group, so it appears in their Physical Resources inventory

$str_return = $ucs_instance + ";" + $ucsc_org + ";" + $ucsc_sp

# Return the string to the task
return $str_return