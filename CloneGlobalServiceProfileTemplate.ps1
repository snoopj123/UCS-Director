Import-Module CiscoUcsCentralPs

$ucsc_org = ($args[0].Split(";"))[1]   # Passing a UCS Director variable and getting the Central Org DN from it
$ucsc_account = ($args[0].Split(";"))[0]  # Passing a UCS Director variable and getting the UCS Central account (if multiples)
$uscs_gspt = ($args[1].Split(";"))[2]  # Passing a UCS Director variable and getting the Global Service Profile Template DN from it
$customer_id = $args[2]  # Passing a string for usage in creating the name of the service profile
$device_sid = $args[3]  # Passing a string for usage in creating the name of the service profile

$ucsc_username = "<insert UCS Central username"
$ucsc_password = ConvertTo-SecureString -String "<insert UCS Central account password or variable, if passing through UCS Director" -AsPlainText -Force
$ucsc_credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ucsc_username, $ucsc_password
$ucsc_conn = Connect-UcsCentral -Name <insert UCS Central FQDN or IP address> -Credential $ucsc_credential

$gsp_name = $customer_id + "-" + $device_sid    # Create combined global service profile name
$new_gsp = Get-UcsCentralServiceProfile -Dn $uscs_gspt | Add-UcsCentralServiceProfileFromTemplate -NamePrefix $gsp_name -Count 1 -DestinationOrg (Get-UcsCentralOrg -Dn $ucsc_org) | Rename-UcsCentralServiceProfile -NewName $gsp_name   # Create GSP from template and rename to remove "1" from end of name

Start-Sleep 15   # Sleep for 15 seconds to allow for UCS Central to process global pool values into GSP
$new_gsp = Get-UcsCentralServiceProfile -Name $new_gsp.Name   # Reload the service profile

$ucsd = @{}   # Create our hashtable to store values

# Create the hashtable values for the various parts of the global service profile to be used by later UCS Director tasks

$ucsd["VNIC1_MAC"] = ($new_gsp | Get-UcsCentralVnic -Name ESX_Mgmt_A).Addr   # MAC for Mgmt NIC/PXE Boot NIC, named ESX_Mgmt_A
$ucsd["VNIC2_MAC"] = ($new_gsp | Get-UcsCentralVnic -Name ESX_Mgmt_B).Addr   # Secondary MAC for Mgmt NIC, named ESX_Mgmt_B
$ucsd["VHBA1_WWPN"] = ($new_gsp | Get-UcsCentralvHBA -Name vHBA1).Addr   # WWPN of vHBA1, used for zoning, named vHBA1
$ucsd["VHBA2_WWPN"] = ($new_gsp | Get-UcsCentralvHBA -Name vHBA2).Addr   # WWPN for vHBA2, used for zoning, named vHBA2
$ucsd["VHBA1_WWN"] = ($new_gsp | Get-UcsCentralvHBA -Name vHBA1).NodeAddr + ":" + ($new_gsp | Get-UcsCentralvHBA -Name vHBA1).Addr  # WWN used for EMC initiator creation for vHBA1
$ucsd["VHBA2_WWN"] = ($new_gsp | Get-UcsCentralvHBA -Name vHBA2).NodeAddr + ":" + ($new_gsp | Get-UcsCentralvHBA -Name vHBA2).Addr  # WWN used for EMC initiator creation for vHBA2
$ucsd["ServiceProfileIdentity"] =  $ucsc_account + ";" + $ucsc_org + ";" + $new_gsp.Dn   # UCS Central Service Profile Identity, in UCS Director variable format

return $ucsd   # Return hashtable to UCS Director for processing with custom task