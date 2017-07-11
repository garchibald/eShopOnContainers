#!/bin/bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
export ESHOP_EXTERNAL_DNS_NAME_OR_IP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
export ESHOP_PROD_EXTERNAL_DNS_NAME_OR_IP=$(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
docker-compose -f docker-compose-local.yml -f docker-compose-local.override.yml up -d --force-recreate
echo eShop started on $(ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)