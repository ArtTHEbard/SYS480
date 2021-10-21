# VM Creation Script
# Author: Sam Johnson
function Connect-Server($server){
# Connect to VI-Server
    $conn = $global:DefaultVIServer
    if($conn){
        Write-Host "Connected" -ForegroundColor Green
    }
    else{
    try {
        Connect-VIServer -Server $server -ErrorAction Stop
        Write-Host "Connected" -ForegroundColor Green
    }
    catch {
        Write-Host "Unable to Connect. Please try again later."
        exit
    }
    }
}

function Converter ($file){
    $defaults = Get-Content $file | ConvertFrom-Json
    return $defaults
    }

function Select-Base-Folder ($defaults) {
# Select Base VM Folder
$folders = Get-Folder -Type VM
Write-Host "Avaliable VM Folders: "
foreach($fold in $folders){
    Write-Host $fold
}
$folder = Read-Host -Prompt "Base VM Folder [Base Vms] "
if ($folder = "Enter"){
    $folder = $defaults.base_folder
}
try {
    $vms = Get-VM -Location $folder -ErrorAction Stop
    Write-Host "Chosen Folder: $folder" -ForegroundColor Green
}
catch {
    Write-Host "Invalid Name" -ForegroundColor Red
    Select-Base-Folder -defaults $defaults
}

foreach($vm in $vms){
   Write-Host $vm
}

}

function Choose_VM {
# Choose a Base VM for clones
    $vm_base = $null
    $vm_choice = Read-Host -Prompt "Choose an avaliable VM "
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

function Choose_VMHost ($defaults){
# Choose the VM Host
    $hosts = Get-VMHost
    Write-Host "Avaliable VM Hosts: " `n $hosts
    $host_choice = Read-Host -Prompt "Please Select VM Host [super9.cyber.local] "
    if ($host_choice = "Enter"){
        $host_choice = $defaults.vm_host
    try {
        $vmhost = Get-VMHost -Name $host_choice -ErrorAction Stop
        Write-Host "Selected Host: $vmhost" -ForegroundColor Green
    }
    catch {
        Write-Host "Invalid Host" -ForegroundColor Red 
        Choose_VMHost -defaults $defaults
    }
    return $vmhost
}
}
function Choose_Data($vmhost, $defaults) {
# Choose the Datastore
    $input = $vmhost
    $datastores = $input | Get-Datastore
    Write-Host "Avaliable VM Datastores: " `n $datastores
    $ds_choice = Read-Host -Prompt "Enter name of datastore "
    if ($ds_choice = "Enter"){
        $ds_choice = $defaults.datastore
    try {
        $ds = Get-Datastore -Name $ds_choice -ErrorAction Stop
        Write-Host "Selected Datastore: $ds" -ForegroundColor Green
    }
    catch {
        Write-Host "Invalid Datastore" -ForegroundColor Red 
        Choose_Data($input)
    }
    return $ds
}
}

function Choose_Name{
# Choose the VM Name
    $name = Read-Host -Prompt "Please enter the name for new VM "
    return $name
}
function Choose_Type{
# Choose the Clone Type
    $type = Read-Host -Prompt "Create a [L]inked Clone or [F]ull Clone? Enter [L] or [F]"

    if ($type -eq "L"){
        Write-Host "Linked Clone Selected" -ForegroundColor Green
        $choice = "Linked"
    }elseif ($type -eq "F") {
        Write-Host "Full Clone Selected" -ForegroundColor Green
        $choice = "Full"
    }else {
        Write-Host "Invlaid Choice" -ForegroundColor Red
        Choose_Type
    } 
    return $choice
}

function Linked_Clone($name, $vm, $vmhost, $data, $defautls){
# Linked Clone Creation
    $base_option = Get-Snapshot -VM $vm
    Write-Host "Avalible Snapshots: " `n $base_option
    $snap_choice = Read-Host -Prompt "Enter name of VM snapshot "
    try {
        $snap = Get-Snapshot -VM $vm -Name $snap_choice -ErrorAction Stop
        Write-Host "Selected Snapshot: $snap" -ForegroundColor Green
    }
    catch {
        Write-Host "No Snapshot Found" -ForegroundColor Red 
        Linked_Clone
    }
    Write-Host "You are about to create a Linked Clone VM with the following inputs:
    Name: $name
    Base VM: $vm
    Snapshot: $snap
    VM Host: $vmhost
    Datastore: $data" -ForegroundColor Cyan
    $choice = Read-Host -Prompt "Would you like to proceed? [Y]/[N]" 
    if ($choice -eq "Y"){
        try{$newvm = New-Vm -name $name -VM $vm -LinkedClone -ReferenceSnapshot $snap -VmHost $vmhost -Datastore $data -ErrorAction Stop
        Write-Host "VM Creation Successful!" -ForegroundColor Green}
        catch{
            Write-Host "Error! Cancelling Operation!" -ForegroundColor Red
            Create_VM
        }
    }elseif ($choice -eq "N"){
        Write-Host "Operation Canceled!" -ForegroundColor Red
        Create_VM
    }else{
        Write-Host "Invalid Answer. Cancelling Operation" -ForegroundColor Red
        Create_VM 
    }
     
}

function Full_Clone($name, $vm, $vmhost, $data, $defaults){
# Full CLone Creation
    $base_option = Get-Snapshot -VM $vm
    Write-Host "Avalible Snapshots: " `n $base_option
    $snap_choice = Read-Host -Prompt "Enter name of VM snapshot "
    try {
        $snap = Get-Snapshot -VM $vm -Name $snap_choice -ErrorAction Stop
        Write-Host "Selected Snapshot: $snap" -ForegroundColor Green
    }
    catch {
        Write-Host "No Snapshot Found" -ForegroundColor Red 
        Linked_Clone
    }
    Write-Host "You are about to create a Full Clone VM with the following inputs:
    Name: $name
    Base VM: $vm
    Snapshot: $snap
    VM Host: $vmhost
    Datastore: $data" -ForegroundColor Cyan
    $choice = Read-Host -Prompt "Would you like to proceed? [Y]/[N]" 
    if ($choice -eq "Y"){
        $linkedname = "{0}.linked" -f $vm.Name
        try {
            $linkedvm = New-Vm -Name $linkedname -VM $vm -LinkedClone -ReferenceSnapshot $snap -VmHost $vmhost -Datastore $data -ErrorAction Stop
            $newvm = New-Vm -name $name -VM $linkedvm -VmHost $vmhost -Datastore $data -ErrorAction Stop
            Write-Host "VM Creation Successful!" -ForegroundColor Green

        }
        catch {
            Write-Host "Error! Cancelling Operation."
            Create_VM
        }
    }elseif ($choice -eq "N"){
        Write-Host "Operation Canceled!" -ForegroundColor Red
        Create_VM
    }else{
        Write-Host "Invalid Answer. Cancelling Operation" -ForegroundColor Red
        Create_VM 
    }
    $del = Read-Host "Delete temporary clone: $linkedvm ? [Y]/[N]" 
    if ($del -eq "Y"){
        try {
            Remove-VM -VM $linkedvm -ErrorAction Stop
            Write-Host "Temp Clone Deleted" -ForegroundColor Green
        }
        catch {
            Write-Host "An Error has occured. Please verify deletion in Vcenter Portal."
        }
    }else {
        Write-Host "Understood. Please delete the temp clone from the Vcenter Portal."
    }  
}


function Network_Adapter($vm, $defautls){
# Change Network Adapter
    $vm = $vm
    $net = Read-Host -Prompt "What network would you like the VM set to "
    $adapter = Get-NetworkAdapter -VM $vm 
    try {
        Set-NetworkAdapter -NetworkAdapter $adapter -NetworkName $net -Confirm:$false -ErrorAction Stop
        Write-Host "Success!" -ForegroundColor Green 
    }
    catch {
        Write-Host "Error! Invalid Network Name"
        Network_Adapter -vm $vm
    }
    
}
function Create_VM{
# Comprehensive Creation Function
    try{
        $defaults = Converter -file "./vars.json"
        Write-Host "File Loaded" -ForegroundColor Green
    } catch{
        Write-Host "File not Found" -ForegroundColor Red
    }
    Connect-Server
    Write-Host "Welcome to the VM Creation Tool!" -ForegroundColor Cyan
    Select-Base-Folder -defaults $defaults
    $vm_base = Choose_VM
    $vmhost = Choose_VMHost -defaults $defaults
    $ds = Choose_Data -vmhost $vmhost -defaults $defaults
    $name = Choose_Name
    $choice = Choose_Type
    if ($choice -eq "Linked"){
        Linked_Clone -name $name -vm $vm_base -vmhost $vmhost -data $ds -defautls $defaults
    }elseif ($choice -eq "Full"){
        Full_Clone -name $name -vm $vm_base -vmhost $vmhost -data $ds -defaults $defaults
    }
    $network = Read-Host -Prompt "Would you like to change the Network Adapter? [Y]/[N]: "
    if ($network -eq "Y"){
        Network_Adapter -vm $name
    }elseif ($network -eq "N") {
        Write-Host "Understood. Proceeding." -ForegroundColor Cyan
    }else {
        Write-Host "Invalid responce processed as N. Proceeding." -ForegroundColor Cyan
    }
    $power = Read-Host -Prompt "Would you like to power on the new VM? [Y]/[N]: " 
    if ($power -eq "Y"){
        Start-VM -VM $name
    }elseif ($power -eq "N") {
        Write-Host "Understood. Proceeding." -ForegroundColor Cyan
    }else {
        Write-Host "Invalid responce processed as N. Proceeding." -ForegroundColor Cyan
}
}
#Github Demo