#!/bin/bash

CONTROLLER="Control_Node"
NETWORK="Network_Node"
COMPUTER="Compute_Node"
STORAGE="Storage_Node"

# start vm
vboxmanage  startvm "$CONTROLLER" &
vboxmanage  startvm "$NETWORK" &
vboxmanage  startvm "$COMPUTER" &
vboxmanage  startvm "$STORAGE" &

