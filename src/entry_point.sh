#!/usr/bin/env sh

set -e
set -x

: ${CLUSTER_ID:?}

: ${AMI:=ami-31328842}
: ${DB_PASSWORD:=iamsoVERYsmart}
: ${DOMAIN:=master.dev.nativ-systems.com}
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
cp /keys/credentials ~/.aws/credentials
cp /keys/config ~/.aws/config

eval $(/tool/set_vars -v "${VPC_NAME}" -s "${SECURITY_GROUP_NAME}" -r "${ROLE_NAME}")

ansible-playbook -i /ansible_hosts /playbooks/instances.yml --extra-vars " \
    clusterid=$CLUSTER_ID \
    security_group_id=$SECURITY_GROUP_ID \
    role=$ROLE_ARN \
    subnet_1=$SUBNET_0 \
    subnet_2=$SUBNET_1 \
    subnet_3=$SUBNET_2 \
    env=$ENV \
    ami=$AMI \
    region=$REGION \
    db_password=$DB_PASSWORD "

eval $(/tool/set_vars -m hosts -c $CLUSTER_ID)

ansible-playbook --check -vvv -i /ansible_hosts /playbooks/mio.yml --extra-vars " \
    db_host=$DB_HOST \
    db_password=$DB_PASSWORD \
    domain=$DOMAIN \
    storage_nodes=$STORAGE_NODES \
    master_nodes=$MASTER_NODES \
    job_nodes=$JOB_NODES \
    index_nodes=$INDEX_NODES
"
