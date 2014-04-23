#!/bin/bash

# debug
set -x 

# if we have wired connection eth0, use it; otherwise use wlan0
if [ `ip link show eth0 | grep "state UP" | wc -l` = "1" ]; then
    BRIDGE_INTERFACE=eth0
else
    BRIDGE_INTERFACE=wlan0 
fi

IMAGE="$HOME/Workspace/OpenStack/ubuntu-12.04.4-server-amd64.iso"

CONTROLLER="Control_Node"
NETWORK="Network_Node"
COMPUTER="Compute_Node"
STORAGE="Storage_Node"



###### cleaning #####
nodes=($CONTROLLER $NETWORK $COMPUTER $STORAGE)
for node in ${nodes[*]}; do 
    if [ `vboxmanage list vms | grep -e "^\"$node\"" | wc -l` != "0" ]; then 
        if [ `vboxmanage list runningvms | grep -e "^\"$node\"" | wc -l` != "0" ]; then 
            vboxmanage controlvm "$node" poweroff
        fi
        
        # are u sure?
        echo "About to delete node: $node"
        echo -n "Do you want to continue [y/N]? "
        read command
        if [[ $command == "y" || $command == "Y" ]]; then
            vboxmanage unregistervm "$CONTROLLER" --delete 
        fi
    fi
done



##### create hostonly interfaces #####
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



##### prepare VM folder #####
VM_DIR="$HOME/.vms"
if [ ! -d "$VM_DIR" ]; then
    mkdir "$VM_DIR"
else
    if [ -f "$VM_DIR/$CONTROLLER.vdi" ]; then rm -f "$VM_DIR/$CONTROLLER.vdi"; fi    
fi



##### create Control Node #####
vboxmanage createvm --name "$CONTROLLER" --register
vboxmanage modifyvm "$CONTROLLER" --memory 2048 --acpi on --boot1 dvd
vboxmanage modifyvm "$CONTROLLER" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$CONTROLLER" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$CONTROLLER" --ostype Ubuntu_64

# add hdd
vboxmanage createhd --filename "$VM_DIR/$CONTROLLER.vdi" --size 10240
vboxmanage storagectl "$CONTROLLER" --name "SATA Controller" --add sata
vboxmanage storageattach "$CONTROLLER" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$CONTROLLER.vdi"



##### create Compute Node #####
vboxmanage createvm --name "$COMPUTER" --register
vboxmanage modifyvm "$COMPUTER" --memory 2048 --acpi on --boot1 dvd
vboxmanage modifyvm "$COMPUTER" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$COMPUTER" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$COMPUTER" --nic3 hostonly --hostonlyadapter3 vboxnet1 
vboxmanage modifyvm "$COMPUTER" --ostype Ubuntu_64

# add hdd
vboxmanage createhd --filename "$VM_DIR/$COMPUTER.vdi" --size 10240
vboxmanage storagectl "$COMPUTER" --name "SATA Controller" --add sata
vboxmanage storageattach "$COMPUTER" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$COMPUTER.vdi"



##### create Network Node #####
vboxmanage createvm --name "$NETWORK" --register
vboxmanage modifyvm "$NETWORK" --memory 1024 --acpi on --boot1 dvd
vboxmanage modifyvm "$NETWORK" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$NETWORK" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$NETWORK" --nic3 hostonly --hostonlyadapter3 vboxnet1 
vboxmanage modifyvm "$NETWORK" --ostype Ubuntu_64

# add hdd
vboxmanage createhd --filename "$VM_DIR/$NETWORK.vdi" --size 10240
vboxmanage storagectl "$NETWORK" --name "SATA Controller" --add sata
vboxmanage storageattach "$NETWORK" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_DIR/$NETWORK.vdi"



##### create Storage Node #####
vboxmanage createvm --name "$STORAGE" --register
vboxmanage modifyvm "$STORAGE" --memory 1024 --acpi on --boot1 dvd
vboxmanage modifyvm "$STORAGE" --nic1 bridged --bridgeadapter1 $BRIDGE_INTERFACE
vboxmanage modifyvm "$STORAGE" --nic2 hostonly --hostonlyadapter2 vboxnet0
vboxmanage modifyvm "$STORAGE" --nic3 hostonly --hostonlyadapter3 vboxnet1 
vboxmanage modifyvm "$STORAGE" --ostype Ubuntu_64

# add hdd
vboxmanage storagectl "$STORAGE" --name "SATA Controller" --add sata

for i in {0..1}; do
    vboxmanage createhd --filename "$VM_DIR/$STORAGE-$i.vdi" --size 20480
    vboxmanage storageattach "$STORAGE" --storagectl "SATA Controller" --port $i --device 0 --type hdd --medium "$VM_DIR/$STORAGE-$i.vdi"
done



###### Add dvds for all nodes ######
for node in ${nodes[*]}; do 
    vboxmanage storagectl "$node" --name "IDE Controller" --add ide
    vboxmanage storageattach "$node" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$IMAGE"
done 

