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
yunohostid=sys.argv[5]

#Get the hostname
hostname = socket.gethostname()
imagename = hostname+'/'+app

#Connect to docker socket
cli = Client(base_url='unix://docker.sock')

# Restore the image
load_tar = open("/home/yunohost.backup/docker/images/"+imagename+".tar", "r")
load_tar.read(load.data)
load = cli.load_image(data=load_tar)
load_tar.close()

#with load_tar = open("/home/yunohost.backup/docker/images/"+imagename+".tar", "r"):
#	load = cli.load_image(data=load_tar)


# Restore the container
import_image = cli.import_image(src="/home/yunohost.backup/docker/containers/"+containername+".tar")

exit()

