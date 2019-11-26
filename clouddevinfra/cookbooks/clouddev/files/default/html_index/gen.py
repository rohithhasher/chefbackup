import boto
from boto.ec2.connection import EC2Connection
from pprint import pprint

from jinja2 import Template
from jinja2 import Environment, PackageLoader

env = Environment(loader=PackageLoader('stats', 'templates'))

conn = EC2Connection('AKIAJRZDPR3NET2EIAMA','vmzXnn+uUAju7mYuo6fTioXyZTa+SeuiLpHvVN3H')
template = env.get_template('machines.html')

reservations = conn.get_all_instances()
instances = [i.__dict__ for r in reservations for i in r.instances]

f =  open("machines.html","w")
f.write(template.render(instances=instances))

