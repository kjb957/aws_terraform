# Devops Project

## Summary
Included are Terraform files that are used to provision the sample app consisting of Portal and Hardware .py in AWS.  The app connects to an RDS MySQL DB and is fronted by a loadbalancer. The front end portal app is hosted in a Public subnet whilst the Harware app and the DB are hosted in a Private network. The apps run on ec2 instances. There are two each of the Public and Private subnets in two different availability zones.

### System Components
* Application Load Balancer - Front end for external web traffic
* Auto Scaling Group - Used for scaling the Portal app accross both availability zones.
* Portal App - Returns a dashboard with results from a query to the hardware app api
* Hardware App - Receives queries from the portal app and returns query results from the DB
* MySQL Database - Hosts data retrieved by the hardware app
* Jumpbox - Allows access from the Public network

### Networking Components
* VPC
* 2 Public & 2 Private Subnets
* Internet Gateway for access to the Public network
* NAT Gateway for access to the Public network from the private subnets

### Notes
* Terraform files are harcoded and would benefit from refactoring to be reusable.
* Database is a single instance
* Hardware app is a single instance but could also in practice be part of a Auto Scaling Group and be fronted with an internal LB.  This was omitted for this exercise since it would be the same setup as for Portal.
* The portal app once fronted by a LB could be hosted in a private network.
* In Security Groups could define source as being other security group object.  Currently using VPC subnet.
* Scaling Policy bug within Terraform for setting ALBRequestCountPerTarget.
* Use Elasticache for solving slow hardware response time, see example of using Redis as a cache below.
* A /test/ route was added to the portal app for manual testing and also as a keep alive health check for the LB.
* A similar route can be added to the hardware app that will send a response for a keep alive health check if fronted by an LB.

### Software Installation
* Each ec2 instance installs and runs software as part of a user data script.  These are the provision_\*.sh scripts. The repo containing the app code is pulled from GitHub.
* Upgrades are accomplished by pushing new code to the git repo and causing a new instance to be provisioned. With the auto scaling group this can be accomplished by increasing then decreasing the desired capacity. The policy will terminate the newest.

Changing the desired capacity in the Auto Scale Group can be accomplished with the following AWS CLI commands
```
aws autoscaling set-desired-capacity --auto-scaling-group-name portal_auto_scale_group --desired-capacity 2 --honor-cooldown
aws autoscaling set-desired-capacity --auto-scaling-group-name portal_auto_scale_group --desired-capacity 1 --honor-cooldown
```

#### Creating the environment
The environment is deployed with Terraform.  The commands to run are as follows.  The commands are run from the directory containing the .tf files.  Copy the required files to the directory where you will run Terraform from.  You can copy Group 1 first and run plan / apply and then add Group 2 and run plan / apply.

* terraform init          # This will download the plugins for AWS.
* terraform plan          # This will show what will happen
* terraform apply         # This will create the objects in AWS
* terraform destroy       # This will destroy all the objects created.

Note that the commands applies to the files and code therein in the folder and represent a state.  Removing them from the directory will result in any objects that were created, be destroyed if we run terraform apply and the files are no longer present. 

#### Using the jumphost
The pem file downloaded from key creation in AWS is used to login to the instances.  The following script / commands will copy the pem file to the jumpbox and will then ssh to that jumpbox.  Thereafter the jumpbox will be able to access the instance.
```
$1 is the first argument (ip address of target host) if a script
#! /bin/bash
scp -i my_default_key_pair.pem my_default_key_pair.pem  ec2-user@$1:
ssh -i my_default_key_pair.pem ec2-user@$1
```
#### Setting up the MySQL DB
Once the DB is created you can access it via the following, where 'hardwareavailability' is the database created during the AWS creation process. The SQL script creates the table and then inserts records to the DB.  At the SQL prompt these commands can be run manually also.  The DB URL is obtained from the AWS console once created.  The database parameters for user, password and host url were copied to the hardware.py script.  The harware should be deployed after the DB is setup otherwise with these changes to the app it will need to be redeployed.  Alternatively setup an alias using a CNAME record in Amazon Route 53 for the FQDN of the DB if you have a domain name.
```
# Connect
mysql -h <host_name> -P 3306 -u <db_master_user> -p
# Create tables and load data
mysql -u <db_master_user> -p hardwareavailability < database_create.sql
```

#### Terraform Files
Group 1
* network_example.tf
  * Deploys the VPC, Public & Private Subnets, Internet Gateway and Routes
* security_groups.tf
  * Deploys Public, Private Security Groups
* jumpbox.tf
  * Deploys the Jumpbox and its security group
* RDS_MySQL.tf
  * Deploys the MySQL DB including its security group
  
Group 2
* nat_gw.tf
  * Deploys the NAT GW and routes for the Private subnets
* ec2_apps_hardware.tf
  * Deploys the hardware app as a single instance and not as part of an Auto Scale Group
* asg_alb_7.tf
  * Application LoadBalancer & Auto Scaling Group Setup

The following terraform configuration objects exist but are not needed as part of the main deploy
* asg_elb_4.tf
  * Classic loadbalancer setup instead of Application Loadbalancer
* ec2_apps_portal.tf
  * Deploys the portal app as a single instance and not as part of an Auto Scale Group
* ec2_apps.tf
  * Deploys the portal and hardware app as single instances and not as part of an Auto Scale Group

#### Auto Scaling Group Based on Incoming Requests
The scaling policy is configured with ALBRequestCountPerTarget which will track the requests sent to the portal app.

#### Cache Locally
To improve CPU bound function
```
import functools
@functools.lru_cache(maxsize=128)
def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])
```

#### Redis Cache Example
Create an AWS Redis Cluster and then amend the hardware code as follows with the cache decorator

```
# Requires pip install python-redis-cache

from redis import StrictRedis
from redis_cache import RedisCache

client = StrictRedis(host="redis_FQDN", decode_responses=True)
cache = RedisCache(redis_client=client)
RedisCache.cache(ttl=60, limit=None, namespace=None)

@cache.cache()
def slow_process_to_calculate_availability(provider, name):
    time.sleep(5)
    return random.choice(['HIGH', 'MEDIUM', 'LOW'])
```


