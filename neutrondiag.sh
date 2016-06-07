#!/bin/bash
echo ""
echo "WARNING!!! This script will prompt for information"
echo ""
echo "Run this script with '| tee -a logfile.txt' to log script output. Also upload the logfile to the case"
###
echo ""
echo "nova list --all-tenants"
nova list --all-tenants --fields name,networks
echo "What is the ID for the instance that can not ping?"
read vmuuid
echo "instance uuid is";echo $vmuuid
nova list --all-tenants |grep $vmuuid
echo "nova show instance"
nova show $vmuuid
echo ""
echo ""
echo "nova console-log instance"
nova console-log $vmuuid
echo ""
echo ""
vmtenant=$(nova show $vmuuid | grep -i tenant_id |cut -d '|' -f3)
echo "vm tenant_id is";echo $vmtenant
router=$(neutron router-list -c id -c name -c tenant_id | grep $vmtenant |cut -d '|' -f2 | cut -b 2-37)
echo "router id is";echo $router
ip netns exec qrouter-$router ip a >> /dev/null 2>&1;if [ $? = 0 ];then echo "The router namespace is located on this controller";else echo "WARNING!!!!!!!!";echo "[ERROR]Please run this script on the controller that hosts the router connected to the provider network. Use neutron l3-agent-list-hosting-router <router-id> to find this.";exit;fi
echo "neutron router-show"
neutron router-show $router
providernetid=$(neutron router-list |grep $router |cut -d '"' -f4)
echo "provider network id is";echo $providernetid
###
echo ""
neutron net-list
echo "neutron net-show public network"
neutron net-show $providernetid
subnetid=$(neutron net-list | grep $providernetid | cut -d '|' -f4)
echo ""
echo "neutron subnet-show public network's subnet"
neutron subnet-show $subnetid
###
echo ""
echo "Show security groups"
neutron security-group-list
secgroupid=$(neutron security-group-list -c name -c id |grep -v + | grep -iv 'id' | cut -d '|' -f3)
for i in $secgroupid;do neutron security-group-show $secgroupid;done
###
echo ""
echo "neutron agent-list"
neutron agent-list
ovsagents=$(neutron agent-list | grep neutron-openvswitch-agent | cut -d '|' -f2)
echo ""
echo "neutron agent-show for each ovs agent"
for i in $ovsagents;do neutron agent-show $ovsagents;done
###
echo ""
echo "neutron agent-show for each l3 agent"
l3agents=$(neutron agent-list | grep neutron-l3-agent | cut -d '|' -f2)
for i in $l3agents;do neutron agent-show $l3agents;done
###
echo ""
echo "ovs-vsctl show"
ovs-vsctl show
echo ""
echo "ip a output"
ip a
echo ""
echo "netstat -rn output"
netstat -rn
###
echo ""
echo "ip netns exect qrouter- ip a"
ip netns exec qrouter-$router ip a
echo ""
externalcidr=$(neutron subnet-show $subnetid | grep cidr | cut -d '|' -f3 | cut -d '.' -f1-2)
echo "first 2 octets of the provider network";echo $externalcidr
vmfloater=$(nova list --all-tenants |grep $vmuuid | grep -Eo "($externalcidr\.([0-9]{1,3}\.)[0-9]{1,3})" )
echo "instance floating ip";echo $vmfloater
echo ""
ip netns exec qrouter-$router ping -c 4 $vmfloater;if [ $? = 0 ];then echo "Can ping instance from within qrouter namespace";else echo "Can not ping instance from within qrouter namespace";fi
echo ""
echo "Attempting to ping the instance from the controller.."
ping -c 4 $vmfloater

