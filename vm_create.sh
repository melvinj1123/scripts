#!/bin/bash
glance image-list
echo "enter the image to be used"
read imageid
neutron net-list
echo "enter the network to be used"
read netid
nova flavor-list
echo "enter the flavor id"
read flavorid
nova secgroup-list
echo "enter the security group to be used"
read secgroup
echo "Give the instance a name..."
read name
nova boot --security-groups $secgroup --image $imageid --flavor $flavorid --nic net-id=$netid $name
nova floating-ip-list
echo "Enter the 4 octet ip address. Example 10.10.10.2"
read floater
nova floating-ip-associate $name $floater
nova list | grep $name
sleep 30
ping -c 3 $floater

