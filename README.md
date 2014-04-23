openstack
=========

All about openstack





Use Virtual Box to create testing environment
=============================================

1. createvm.sh
   
   To clean the environment, create network interfaces and create virtual machines. You have 
   to change variable IMAGE to point to your own image.

2. startvm.sh
   
   Start all machines to install the base system.

3. ejectdvd.sh

   To eject dvds after installation.

Remember to eject dvds after you finish the installation. Otherwise if might install the 
system again. After ejecting dvds, you can start machines using: 
```
        ./startvm.sh
```