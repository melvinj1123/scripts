#!/bin/bash
#Created by Jmelvin
echo "Get stack resource"
heat stack-list
Stackid=$(heat stack-list | awk 'NR==4{print}' | cut -d'|' -f2)
echo "finding failed deployment resources"
heat resource-list $Stackid | grep -i fail
Resourceid=$(heat resource-list $Stackid | grep -i fail | awk 'NR==1{print}' | cut -d'|' -f3)
echo "show first failed resource resource id"
heat resource-list $Resourceid
Failed2=$(heat resource-list $Resourceid | grep -i fail | awk 'NR==1{print}' | cut -d'|' -f3)
echo "show first faild resource names"
heat resource-list $Failed2
Deployinfo=$(heat resource-list $Failed2 | grep -i fail | awk 'NR==1{print}' | cut -d'|' -f3)
echo "show info about the first failed resource"
heat deployment-show $Deployinfo
#
echo "show second failed resource resource id"
Resourceid=$(heat resource-list $Stackid | grep -i 'fail\|progress' | awk 'NR==2{print}' | cut -d'|' -f3)
heat resource-list $Resourceid
Failed2=$(heat resource-list $Resourceid | grep -i 'fail\|progress' | awk 'NR==1{print}' | cut -d'|' -f3)
echo "show second faild resource names"
heat resource-list $Failed2
Deployinfo=$(heat resource-list $Failed2 | grep -i 'fail\|progress' | awk 'NR==1{print}' | cut -d'|' -f3)
echo "show info about the second failed resource"
heat deployment-show $Deployinfo
