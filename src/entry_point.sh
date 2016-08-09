#!/usr/bin/env sh

set -e
set -x

: ${CLUSTER_ID:?}

: ${AMI:=ami-31328842}
: ${DB_PASSWORD:=iamsoVERYsmart}
: ${DOMAIN:=master.dev.nativ-systems.com}
: ${ENV:=t}
: ${IPCODE:=P386}
: ${REGION:=eu-west-1}
: ${ROLE_NAME:=FTMioRole}
: ${SECURITY_GROUP_NAME:=ESR-Video-Test-VPC-Resources-SG}
: ${VPC_NAME:=ESR-Video-Test-VPC}

: ${OOYALA_PASSWORD:?}

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
cat > ~/.ssh/config <<EOF
Host 10.*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

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
    web_security_group_id=$WEB_SECURITY_GROUP_ID \
    private_security_group_id=$PRIVATE_SECURITY_GROUP_ID \
    role=$ROLE_ARN \
    public_subnet_1=$PUBLIC_SUBNET_0 \
    public_subnet_2=$PUBLIC_SUBNET_1 \
    public_subnet_3=$PUBLIC_SUBNET_2 \
    private_subnet_1=$PRIVATE_SUBNET_0 \
    private_subnet_2=$PRIVATE_SUBNET_1 \
    private_subnet_3=$PRIVATE_SUBNET_2 \
    env=$ENV \
    ami=$AMI \
    region=$REGION \
    ipcode=$IPCODE \
    db_password=$DB_PASSWORD "

eval $(/tool/set_vars -m hosts -v "${VPC_NAME}" -c "${CLUSTER_ID}")

ansible-playbook -vvv -i /ansible_hosts /playbooks/mio.yml --extra-vars " \
    clusterid=$CLUSTER_ID \
    db_host=$DB_HOST \
    db_password=$DB_PASSWORD \
    domain=$DOMAIN \
    storage_nodes=$STORAGE_NODES \
    master_nodes=$MASTER_NODES \
    mongo_nodes=$MONGO_NODES \
    ooyala_password=$OOYALA_PASSWORD
"
