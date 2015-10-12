Import-Module CiscoUcsCentralPs

$ucsc_sp = ($args[0].Split(";"))[2]
$ucsc_server = ($args[1].Split(";"))[1]

$ucsc_username = "UCS Central Account"
$ucsc_password = ConvertTo-SecureString -String "UCS Central Account Password" -AsPlainText -Force
$ucsc_credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ucsc_username, $ucsc_password
$ucsc_conn = Connect-UcsCentral -Name "UCS Central IP/Name" -Credential $ucsc_credential


# Start the Global Service Profile Disassociation Process
$command_1 = Disconnect-UcsCentralServiceProfile -ServiceProfile (Get-UcsCentralServiceProfile -Dn $ucsc_sp) -Force -Confirm:$false

# Keep an eye on the UCS device to ensure we have full disassociation and server is set to "Unassociated"

if ($ucsc_server -match "rack-unit")  # for a UCS C-Series
{
    do {Start-Sleep 10;$sp = Get-UcsCentralRackUnit -Dn $ucsc_server} while ($sp.OperState -ne "unassociated")
}
else   # for a UCS B-Series
{
    do {Start-Sleep 10;$sp = Get-UcsCentralBlade -Dn $ucsc_server} while ($sp.OperState -ne "unassociated")
}

Disconnect-UcsCentral -UcsCentral $ucsc_conn