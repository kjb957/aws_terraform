#! /bin/bash
yum -y install git
git clone https://github.com/kjb957/rescale.git /home/ec2-user/rescale
pip install -r /home/ec2-user/rescale/requirements.txt
# Simple run of app.  To survive reboot would need to define a service
python /home/ec2-user/rescale/hardware.py
