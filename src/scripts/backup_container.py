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

# Save the image
save = cli.get_image(image=imagename)
save_tar = open("/home/yunohost.backup/docker/images/"+imagename+".tar", "w")
save_tar.write(save.data)
save_tar.close()

# Save the container
export = cli.export(container=containername)
export_tar = open("/home/yunohost.backup/docker/containers/"+containername+".tar", "w")
export_tar.write(export.data)
export_tar.close()

exit()

