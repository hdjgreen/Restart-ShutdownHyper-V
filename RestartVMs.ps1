# The invocation script only apply for machines for WES09 testing,
# you need to do some required changes if you want to use the script

Import-Module -Name ".\Invoke-VMs" -Force -ErrorAction Stop

#Run-StartVM -servername embedded-1    -computername "XPE/WES09_WES09IE7WMP11(2)","XPE/WES09_WES09IE8(2)"                    -snapshotname "CleanProduct-Close Status"
#Run-StartVM -servername embeddedwin-2 -computername "XPE/WES09_WES09-3"                                                     -snapshotname "CleanProduct-Close Status"
#Run-StartVM -servername webchina024   -computername "XPE/WES09_WES09-4I","XPE/WES09_WES09IE7WMP11-4","XPE/WES09_WES09IE8-4" -snapshotname "CleanProduct-Close Status"
Run-StartVM -servername wes09server2  -computername "XPE/WES09_WES09IE7WMP11-3","XPE/WES09_WES09IE8-3"                      -snapshotname "CleanProduct-Close Status"
Run-StartVM -servername wes09server3  -computername "XPE/WES09_WES09(2)"                                                    -snapshotname "CleanProduct-Close Status"




