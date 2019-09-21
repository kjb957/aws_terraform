#! /bin/bash
git clone https://github.com/rescale/devops-homework.git /home/ec2-user/.
pip install -r /home/ec2-user/devops-homework/requirements.txt
python /home/ec2-user/devops-homework/portal.py