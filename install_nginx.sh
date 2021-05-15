#!/bin/bash
apt-get -y update
apt-get -y install nginx
systemctl restart nginx
