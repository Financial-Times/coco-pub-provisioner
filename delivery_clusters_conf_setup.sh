#!/bin/bash

# This script sets up ECTD configurations for communications to COCO delivery clusters via HTTP
# DELIVERY_CONFIG_PARAM="dynpub,http://pippo.com/pluto,user1,passwd1;pre-prod,http://pluto.com/pippo,user2,passwd2"

if [[ -z $1 ]]; then
    echo "Error: Configuration string is missing"
	exit
fi

IFS='; ' read -r -a ENV_CONFIGS <<< $1
for ENV_CONFIG in "${ENV_CONFIGS[@]}"
do
	IFS=', ' read -r -a ENV_CONFIG_DETAILS <<< $ENV_CONFIG
	etcdctl mk /ft/config/publish-availability-monitor/delivery-environments/${ENV_CONFIG_DETAILS[0]}/read-url  ${ENV_CONFIG_DETAILS[1]}
	etcdctl mk /ft/_credentials/coco-delivery/${ENV_CONFIG_DETAILS[0]}/username  ${ENV_CONFIG_DETAILS[2]}
	etcdctl mk /ft/_credentials/coco-delivery/${ENV_CONFIG_DETAILS[0]}/password  ${ENV_CONFIG_DETAILS[3]}
done