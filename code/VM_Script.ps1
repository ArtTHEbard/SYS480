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
$vms = Get-VM -Location $folder
Write-Host "Avaliable Base VMs: " 
Write-Host $vms.Name
}

function Choose_Type {
$vm_base = Read-Host -Prompt "Choose an avaliable VM: "
$type = Read-Host -Prompt "Create a [L]inked Clone or [F]ull Clone? Enter [L] or [F]"

if ($type = "L"){
    Linked_Clone
}elseif ($type = "F") {
    Full_Clone
}else {
    Write-Host "Invlaid Choice" -ForegroundColor Red
    Repeat_Choose
}
}

function Repeat_Choose{
    Choose_Type
}
function Linked_Clone{
    Write-Host "Linked Clone Selected" -ForegroundColor Green
}

function Full_Clone{
    Write-Host "Full Clone Selected" -ForegroundColor Green
}


Connect-Server
Select-Base-Folder
Choose_Type

