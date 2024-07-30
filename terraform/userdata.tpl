#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx.service
sudo rm -Rf /usr/share/nginx/html/*
sudo mv /tmp/dist/* /usr/share/nginx/html/