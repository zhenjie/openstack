#!/bin/sh

# debug
set -x 

# if we have wireless connection, use it; otherwise use eth0
if [ `vboxmanage list bridgedifs | grep -e "Name: *wlan0" | wc -l` = "1" ]; then
    BRIDGE_INTERFACE=wlan0
else
    BRIDGE_INTERFACE=eth0 
fi

IMAGE="$HOME/Workspace/OpenStack/ubuntu-12.04.4-server-amd64.iso"

CONTROLLER="Control_Node"
NETWORK="Network_Node"
COMPUTER="Compute_Node"
STORAGE="Storage_Node"

# cleaning
if [ `vboxmanage list vms | grep -e "^\"$CONTROLLER\"" | wc -l` != "0" ]; then 
    if [ `vboxmanage list runningvms | grep -e "^\"$CONTROLLER\"" | wc -l` != "0" ]; then 
        vboxmanage controlvm "$CONTROLLER" poweroff
    fi

    vboxmanage unregistervm "$CONTROLLER" --delete 
fi

if [ `vboxmanage list vms | grep -e "^\"$NETWORK\"" | wc -l` != "0" ]; then 
    if [ `vboxmanage list runningvms | grep -e "^\"$NETWORK\"" | wc -l` != "0" ]; then 
        vboxmanage controlvm "$NETWORK" poweroff
    fi

    vboxmanage unregistervm "$NETWORK" --delete 
fi

if [ `vboxmanage list vms | grep -e "^\"$COMPUTER\"" | wc -l` != "0" ]; then 
    if [ `vboxmanage list runningvms | grep -e "^\"$COMPUTER\"" | wc -l` != "0" ]; then 
        vboxmanage controlvm "$COMPUTER" poweroff
    fi

    vboxmanage unregistervm "$COMPUTER" --delete 
fi

if [ `vboxmanage list vms | grep -e "^\"$STORAGE\"" | wc -l` != "0" ]; then 
    if [ `vboxmanage list runningvms | grep -e "^\"$STORAGE\"" | wc -l` != "0" ]; then 
        vboxmanage controlvm "$STORAGE" poweroff
    fi

    vboxmanage unregistervm "$STORAGE" --delete 
fi

# create hostonly interfaces
if [ `vboxmanage list hostonlyifs | grep "vboxnet0" | wc -l` != 0 ]; then 
    vboxmanage hostonlyif remove vboxnet0
fi
if [ `vboxmanage list hostonlyifs | grep "vboxnet1" | wc -l` != 0 ]; then 
    vboxmanage hostonlyif remove vboxnet1
fi

vboxmanage hostonlyif create
vboxmanage hostonlyif ipconfig vboxnet0 --ip 10.10.0.1 --netmask 255.255.255.0

vboxmanage hostonlyif create
vboxmanage hostonlyif ipconfig vboxnet1 --ip 10.10.10.1 --netmask 255.255.255.0


# prepare VM folder 
VM_DIR="$HOME/.vms"
if [ ! -d "$VM_DIR" ]; then
    mkdir "$VM_DIR"
else
    if [ -f "$VM_DIR/$CONTROLLER.vdi" ]; then rm -f "$VM_DIR/$CONTROLLER.vdi"; fi    
fi


### create Controller ###
vboxmanage createvm --name "$CONTROLLER" --register
vboxmanage modifyvm "$CONTROLLER" --memory 2048 --acpi on --boot1 dvd
vboxmanage modifyvm "$CONTROLLER" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$CONTROLLER" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$CONTROLLER" --ostype Ubuntu_64

# add cd/dvd
vboxmanage storagectl "$CONTROLLER" --name "IDE Controller" --add ide
vboxmanage storageattach "$CONTROLLER" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$IMAGE"

# add hdd
vboxmanage createhd --filename "$VM_DIR/$CONTROLLER.vdi" --size 10240
vboxmanage storagectl "$CONTROLLER" --name "SATA Controller" --add sata
vboxmanage storageattach "$CONTROLLER" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$CONTROLLER.vdi"

# start to install the system
# vboxmanage  startvm "$CONTROLLER" &

# eject dvd
# vboxmanage modifyvm "$CONTROLLER" --dvd none



### create Computer ###
vboxmanage createvm --name "$COMPUTER" --register
vboxmanage modifyvm "$COMPUTER" --memory 2048 --acpi on --boot1 dvd
vboxmanage modifyvm "$COMPUTER" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$COMPUTER" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$COMPUTER" --nic3 hostonly --hostonlyadapter3 vboxnet1 
vboxmanage modifyvm "$COMPUTER" --ostype Ubuntu_64

# add cd/dvd
vboxmanage storagectl "$COMPUTER" --name "IDE Controller" --add ide
vboxmanage storageattach "$COMPUTER" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$IMAGE"

# add hdd
vboxmanage createhd --filename "$VM_DIR/$COMPUTER.vdi" --size 10240
vboxmanage storagectl "$COMPUTER" --name "SATA Controller" --add sata
vboxmanage storageattach "$COMPUTER" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$COMPUTER.vdi"

# start to install the system
# vboxmanage  startvm "$COMPUTER" &

# eject dvd
# vboxmanage modifyvm "$COMPUTER" --dvd none


### create Network ###
vboxmanage createvm --name "$NETWORK" --register
vboxmanage modifyvm "$NETWORK" --memory 1024 --acpi on --boot1 dvd
vboxmanage modifyvm "$NETWORK" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$NETWORK" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$NETWORK" --nic3 hostonly --hostonlyadapter3 vboxnet1 
vboxmanage modifyvm "$NETWORK" --ostype Ubuntu_64

# add cd/dvd
vboxmanage storagectl "$NETWORK" --name "IDE Controller" --add ide
vboxmanage storageattach "$NETWORK" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$IMAGE"

# add hdd
vboxmanage createhd --filename "$VM_DIR/$NETWORK.vdi" --size 10240
vboxmanage storagectl "$NETWORK" --name "SATA Controller" --add sata
vboxmanage storageattach "$NETWORK" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$NETWORK.vdi"

# start to install the system
# vboxmanage  startvm "$NETWORK" &

# eject dvd
# vboxmanage modifyvm "$NETWORK" --dvd none


### create Storage ###
vboxmanage createvm --name "$STORAGE" --register
vboxmanage modifyvm "$STORAGE" --memory 1024 --acpi on --boot1 dvd
vboxmanage modifyvm "$STORAGE" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$STORAGE" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$STORAGE" --nic3 hostonly --hostonlyadapter3 vboxnet1 
vboxmanage modifyvm "$STORAGE" --ostype Ubuntu_64

# add cd/dvd
vboxmanage storagectl "$STORAGE" --name "IDE Controller" --add ide
vboxmanage storageattach "$STORAGE" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$IMAGE"

# add hdd
vboxmanage createhd --filename "$VM_DIR/$STORAGE-1.vdi" --size 20480
vboxmanage storagectl "$STORAGE" --name "SATA Controller" --add sata
vboxmanage storageattach "$STORAGE" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$STORAGE-1.vdi"

vboxmanage createhd --filename "$VM_DIR/$STORAGE-2.vdi" --size 20480
vboxmanage storageattach "$STORAGE" --storagectl "SATA Controller" --port 1 --device 0 --type hdd --medium "$VM_DIR/$STORAGE-2.vdi"

