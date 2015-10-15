# UCS-Director
UCS Director PowerShell Scripts

This repo contains the following scripts:

1) AssociateGlobalServiceProfile.ps1 - A UCS Central PowerTool script that will can be used in a UCS Director workflow to associate a global service profile to either a UCS B-Series blade or a UCS C-Series rackmount server (currently an issue using UCS Director's UCS Central association task to a C-Series)

2) DisassociateGlobalServiceProfile.ps1 - A UCS Central PowerTool script that can be used in a UCS Director workflow to disassociate a global service profile to either a UCS B-Series blade or a UCS C-Series rackmount server (same as #1, issue with UCS C-Series)

3) CloneGlobalServiceProfileTemplates.ps1 - A UCS Central PowerTool script that can be used to clone a global service profile (GSP) from a global service profile template (GSPT).  This script resolves an issue I was having in which the UCS Director task to perform this operation had a tendancy to return values of "derived" for items I knew should have been returning back values from global pools (like vNIC MAC addresses and vHBA WWPN addresses).  I resolve the issue by putting a forced sleep command to allow Central to process the values from the global pools and then forcing another read of the profile to get the updated information.  Script returns a hash table of values that I felt were needed for my overall UCS Director workflows to function (like vNIC MACs, WWNs for EMC storage initiator creation, and WWPNs for storage zoning in an FC SAN switching environment)

4) RemoveGlobalServiceProfile.ps1 - A UCS Central PowerTool script that can be used to delete a global service profile (GSP) from UCS Central.  I use this script as the rollback to script #3 (the clone script).