#!/usr/bin/env sh

set -e
set -x

: ${AWS_ACCESS_KEY:?}
: ${AWS_SECRET_KEY:?}
: ${CLUSTER_ID:?}

: ${AMI:=ami-31328842}
: ${DB_PASSWORD:=iamsoVERYsmart}
: ${ENV:=p}
: ${REGION:=eu-west-1}
: ${ROLE_NAME:=MioRole}
: ${SECURITY_GROUP_NAME:=default}
: ${VPC_NAME:=default}

cat > /ansible_hosts <<EOF
[localhost]
127.0.0.1
EOF

mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = ${AWS_ACCESS_KEY}
aws_secret_access_key = ${AWS_SECRET_KEY}
EOF

cat > ~/.aws/config <<EOF
[default]
region = eu-west-1
EOF

eval $(/tool/set_vars -v "${VPC_NAME}" -s "${SECURITY_GROUP_NAME}" -r "${ROLE_NAME}")

ansible-playbook -vvv -i /ansible_hosts /playbooks/instances.yml --extra-vars " \
    clusterid=$CLUSTER_ID \
    aws_access_key_id=$AWS_ACCESS_KEY \
    aws_secret_access_key=$AWS_SECRET_KEY \
    security_group_id=$SECURITY_GROUP_ID \
    role=$ROLE_ARN \
    subnet_1=$SUBNET_0 \
    subnet_2=$SUBNET_1 \
    subnet_3=$SUBNET_2 \
    env=$ENV \
    ami=$AMI \
    region=$REGION \
    db_password=$DB_PASSWORD "
