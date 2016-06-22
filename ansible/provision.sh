#!/bin/bash

set -u # Variables must be explicit
set -e # If any command fails, fail the whole thing
set -o pipefail

# Make sure SSH knows to use the correct pem
ssh-add hello-world.pem
ssh-add -l
# Load the AWS keys
. ./inventory/aws_keys

# Ensure the app's cache is up to date
inventory/ec2.py --refresh-cache

# Tag any existing instances as being old

ansible-playbook tag-old-nodes.yaml --limit tag_Environment_hello_world || true



echo "DONE!"
# Start a new instance
ansible-playbook immutable.yaml

# Ensure the app's cache is up to date
inventory/ec2.py --refresh-cache

# Now terminate any instances with tag "old"

ansible-playbook destroy-old-nodes.yaml -u ubuntu --limit tag_oldhello_world_True || true


echo "site updated"
