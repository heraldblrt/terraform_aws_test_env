#!/bin/bash

#Todo! change the settings.py, insert the ip number of ALLOWED_HOSTS

#cp requirement.txt fluwd_automation/acl_project/

#python3 -m venv myEnv

/usr/bin/pip3 install -r requirement.txt

# cd fluwd_automation folder
#cd fluwd_automation/acl_project/

#source myEnv/bin/activate

#todo use ansible or puppet to auto insertion of ip number or domain name into ALLOWED_HOSTS in settings.py 
# settings.py location : /home/ubuntu/fluwd_automation/acl_project/acl_project/settings.py

# Run Migrations and Start the Django Development Server
#python3 manage.py migrate
python3 fluwd_automation/acl_project/manage.py runserver 0.0.0.0:8000

#todo setup the nginx to handle reverse proxy