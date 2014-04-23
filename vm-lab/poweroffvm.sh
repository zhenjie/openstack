#!/bin/bash

CONTROLLER="Control_Node"
NETWORK="Network_Node"
COMPUTER="Compute_Node"
STORAGE="Storage_Node"

vboxmanage controlvm "$CONTROLLER" poweroff & 
vboxmanage controlvm "$NETWORK" poweroff &
vboxmanage controlvm "$COMPUTER" poweroff &
vboxmanage controlvm "$STORAGE" poweroff &