Function Run-StartVM
{
	param(
		[string] $servername = $(throw "Parameter of server name should be string"), 
		#search for all of computers on the server that snapshot names named as $snapshotname if this parameter is null, 
		#otherwise search for specify the snapshot of the computer on the server
		[array] $computername,
		[string] $snapshotname = $(throw "Parameter of snapshot name should be string")
		)

    foreach($name in $computername)
    {
        if($Script:IsWin10 -and $Script:IsLocalMachine)
        {   
            $Prompt = "####   Getting snapshot of virtual machine {0} on server {1}   ####" -f $name,$servername
            Write-Host $Prompt -foregroundcolor Green

            #get virtual machine snapshot
	        $VmSnapshots = Invoke-Command -ComputerName $servername -ScriptBlock {param($Server,$Snapshot,$name) Get-VM -ComputerName $Server | 
							Where-Object{$_.Name -eq $name}| Get-VMSnapshot -Name $Snapshot} -ArgumentList $servername, $SnapshotName, $name
            

            #restore specified virtual machine snaphsot
            $Prompt = "####   Restoring snapshot {0} on virtual machine {1}   ####" -f $snapshotname,$name
            Write-Host $Prompt -foregroundcolor Green

            Invoke-Command -ComputerName $servername -ScriptBlock {param($Snapshot,$name)
                Restore-VMSnapshot -Name $Snapshot -VMName $name  -Confirm:$false} -ArgumentList $SnapshotName,$name
            
            #invoke method to start specified virtual machine snapshot if it is closed.
            StartupVM $VmSnapshots $servername

	    }
        else
        {
            $Prompt = "####   Getting snapshot of virtual machine {0} on server {1}   ####" -f $name,$servername
            Write-Host $Prompt -foregroundcolor Green

			$VmSnapshots = Get-VM -ComputerName $servername | Where-Object{$_.Name -eq $name} | Get-VMSnapshot -Name $SnapshotName

            $Prompt = "####   Restoring snapshot {0} on virtual machine {1}   ####" -f $snapshotname,$name
            Write-Host $Prompt -foregroundcolor Green

            $VmSnapshots | Restore-VMSnapshot -Confirm: $false

            StartupVM $VmSnapshots $servername
        }
    }
}

# Will snapshot to start if its status is closed
Function StartupVM($vm, $serverName)
{
    $Prompt = "####   Starting virtual machine {0}  ####" -f $vm.VMName
    Write-Host $Prompt  -foregroundcolor Green

    if($Script:IsWin10 -and $Script:IsLocalMachine)
    {
        Invoke-Command -ComputerName $serverName -ScriptBlock {param($vm) Start-VM -Name ($vm).VMName} -ArgumentList $vm
    }
    else
    {
        Start-VM -Name $vm.VMName -ComputerName $serverName
    }

}

Function Run-ShutdownVM
{
	param(
        [string] $servername = $(throw "Parameter of server name should be string"), 
		[array] $computername
		)
		
	foreach($name in $computername)
    {                     
        ShutdownVM $name $servername
    }
}

Function ShutdownVM($vm, $serverName)
{
	$Prompt = "####   Shutting down virtual machine {0} on server {1}   ####" -f $vm,$serverName
    Write-Host $Prompt -foregroundcolor Green

    if($Script:IsWin10 -and $Script:IsLocalMachine)
    {
        Invoke-Command -ComputerName $serverName -ScriptBlock {param($vm) Stop-VM -Name $vm -Force –TurnOff} -ArgumentList $vm
    }
    else
    {
        Stop-VM -Name $vm -ComputerName $serverName -Force –TurnOff
    }
}

# judge whether is Windows10, due to powershell version on Win10 is incompatible with servers',
# it needs to special processing
Function IsWin10
{
    $version = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExcludeProperty Caption
    Write-Host "##Getting OS version" -foregroundcolor Green
    if($version.Version.Split(".")[0] -eq '10')
    {
        return $true
    }
    else
    {
        return $false
    } 
}

# judge whether is local machine, not need to performe Invoke-Command if it is local macine
Function IsLocalMachine
{
    return $env:COMPUTERNAME -ne $ServerName
}

#########################   Implementation part      ##########################
$Script:IsWin10 = IsWin10
$Script:IsLocalMachine = IsLocalMachine

Export-ModuleMember -Function Run-StartVM,Run-ShutdownVM

