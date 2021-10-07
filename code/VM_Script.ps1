# VM Creation Script
# Author: Sam Johnson
function Connect-Server {
# Connect to VI-Server
Connect-VIServer -Server vcenter.sjohnson.local -User "sjohnson-adm" -Password "Thebainted1"
$msg1 = "Connected"
Write-Host $msg1 -ForegroundColor Green
}

function Select-Base-Folder {
# Select Base VM Folder
$folder = Read-Host -Prompt "Base VM Folder: "
try {
    $vms = Get-VM -Location $folder -ErrorAction Stop
    Write-Host "Chosen Folder: $folder" -ForegroundColor Green
}
catch {
    Write-Host "Invalid Name" -ForegroundColor Red
    Select-Base-Folder
}

foreach($vm in $vms){
   Write-Host $vm
}

}

function Choose_VM {
    $vm_base = $null
    $vm_choice = Read-Host -Prompt "Choose an avaliable VM: "
    try {
        $vm_base = Get-Vm -Name $vm_choice -ErrorAction Stop
        Write-Host "Chosen VM: $vm_base" -ForegroundColor Green
    }
    catch {
            Write-Host "Invalid VM Name" -ForegroundColor Red
        Choose_VM
    }
    return $vm_base
}

function Choose_VMHost_Data{
    $hosts = Get-VMHost
    $vmhost = $null
    Write-Host "Avaliable VM Hosts: " `n $hosts
    $host_choice = Read-Host -Prompt "Please Select VM Host: "
    try {
        $vmhost = Get-VMHost -Name $host_choice -ErrorAction Stop
        Write-Host "Selected Host: $vmhost" -ForegroundColor Green
    }
    catch {
        Write-Host "Invalid Host" -ForegroundColor Red 
        Choose_VMHost
    }
    $ds = $null
    $datastores = $vmhost | Get-Datastore
    Write-Host "Avaliable VM Datastores: " `n $datastores
    $ds_choice = Read-Host -Prompt "Enter name of datastore: "
    try {
        $ds = Get-VMHost -Name $ds_choice -ErrorAction Stop
        Write-Host "Selected Datastore: $ds" -ForegroundColor Green
    }
    catch {
        Write-Host "Invalid Datastore" -ForegroundColor Red 
        Choose_Datastore
    }
    return $vmhost, $ds
}


function Choose_Type{
    $type = Read-Host -Prompt "Create a [L]inked Clone or [F]ull Clone? Enter [L] or [F]"

    if ($type -eq "L"){
        Write-Host "Linked Clone Selected" -ForegroundColor Green
        Linked_Clone
    }elseif ($type -eq "F") {
        Write-Host "Full Clone Selected" -ForegroundColor Green
        Full_Clone
    }else {
        Write-Host "Invlaid Choice" -ForegroundColor Red
        Choose_Type
    } 
}

function Linked_Clone{
    $snap_choice = Read-Host -Prompt "Enter name of VM snapshot: "
    try {
        $snap = Get-Snapshot -VM $vm_base -Name $snap_choice
    }
    catch {
        Write-Host "No Snapshot Found" -ForegroundColor Red -ErrorAction Stop
        Linked_Clone

    }

}

function Full_Clone{
    
}


Connect-Server
#$basefolder= Select-Base-Folder
#$vm_base = Choose_VM
Choose_VMHost_Data
Write-Host $vmhost $ds
#Choose_Type

