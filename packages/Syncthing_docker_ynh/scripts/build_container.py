#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import socket
import sys
import re
from docker import Client

app=sys.argv[1]
username=sys.argv[2]
datapath=sys.argv[3]
containername=sys.argv[4]
containerports=sys.argv[5]
yunohostid=sys.argv[6]
dockerized=sys.argv[7]

#Get the hostname
hostname = socket.gethostname()
imagename = hostname+'/'+app
tab_ports = {}

#Connect to docker socket
cli = Client(base_url='unix://docker.sock')

#Define port binding
if dockerized:
	config=cli.create_host_config(network_mode='container:'+yunohostid)
else:
	for port in containerports:
		tab_ports[port]=('127.0.0.1',port)

	config=cli.create_host_config(port_bindings=tab_ports)

#Build docker image with the Dockerfile and disply the output
for line in cli.build(path='../build/', tag=imagename, rm=True):
	out = json.loads(line)
	#sys.stdout.write('\r')
	#print(out['stream'])
	#sys.stdout.flush()

#Create the container and display result
app_user=re.split("_",app)
app_user=app_user[0]
container = cli.create_container(
			image=imagename,  
			tty=True,
			volumes=[datapath+":/home/"+app_user+"/data", "/home/yunohost.docker/container-"+app+"/"+username+"/config:/home/"+app_user+"/.config"], 
			name=containername,
			ports=containerports,
			host_config=config
)		

#Start the container and display result
cli.start(container=containername)

details=cli.inspect_container(container=containername)

exit()

