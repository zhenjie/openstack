#!/bin/sh

CONTROLLER="Control_Node"
NETWORK="Network_Node"
COMPUTER="Compute_Node"
STORAGE="Storage_Node"

vboxmanage modifyvm "$CONTROLLER" --dvd none
vboxmanage modifyvm "$NETWORK" --dvd none
vboxmanage modifyvm "$COMPUTER" --dvd none
vboxmanage modifyvm "$STORAGE" --dvd none
