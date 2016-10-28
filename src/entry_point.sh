#!/usr/bin/env sh

set -e
set -x
set -a

: ${MODE:=box}
: ${BUILDOUT:=install}

if [[ "${MODE}" != 'infrastructure' ]]; then
    : ${CLUSTER_ID:?}
else
    : ${CLUSTER_ID:=infra}
fi

: ${AMI:=ami-31328842}
: ${CONSUL:=localhost:8500}
: ${CLUSTERED:=false}
: ${DB_MASTERPASSWORD:=iamsoVERYsmart}
: ${DB_MASTERUSERNAME:=admin}
: ${DB_PASSWORD:=somethingsensible}
: ${DOMAIN:=master.dev.nativ-systems.com}
: ${ELASTICSEARCH_CLUSTERNAME:=elasticsearch}
: ${ENV:=t}
: ${IPCODE:=P386}
: ${JAR_VERSION:=latest}
: ${MASTERUSER_PASSWORD:=masteruser}
: ${MONGO_DATABASE:=flex}
: ${MONGO_MASTERUSERNAME:=admin}
: ${MONGO_MASTERPASSWORD:=iamsoVERYsmart}
: ${MONGO_REPLICASET:=''}
: ${RABBIT_HOST:=localhost}
: ${RABBIT_PASSWORD:=flex}
: ${RABBIT_USERNAME:=flex}
: ${RABBIT_VHOST:=flex}
: ${REGION:=eu-west-1}
: ${ROLE_NAME:=FTMioRole}
: ${SECURITY_GROUP_NAME:=ESR-Video-Test-VPC-Resources-SG}
: ${SMTP_REPLAY:=smtp.svc.ft.com}
: ${VPC_NAME:=ESR-Video-Test-VPC}

[ -f /.env ] && source /.env

: ${OOYALA_PASSWORD:?}

export DB_DATABASE=${CLUSTER_ID}_master
export DB_USERNAME=${CLUSTER_ID}
export MONGO_DATABASE=${CLUSTER_ID}
export MONGO_USERNAME=${CLUSTER_ID}
export MONGO_PASSWORD=${DB_PASSWORD}

mkdir -p ~/.ssh
touch ~/.ssh/known_hosts
cat > ~/.ssh/config <<EOF
Host 10.*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

# cat > /ansible_hosts <<EOF
# [localhost]
# 127.0.0.1
# EOF

touch /ansible_hosts

mkdir -p ~/.aws
cp /keys/credentials ~/.aws/credentials
cp /keys/config ~/.aws/config

if [[ "${BUILDOUT}" = 'build' ]]; then
    eval $(/tool/set_vars -v "${VPC_NAME}" -s "${SECURITY_GROUP_NAME}" -r "${ROLE_NAME}")

    ansible-playbook -i /ansible_hosts "/playbooks/${MODE}/hosts.yml" --extra-vars " \
      ami=$AMI \
      clusterid=$CLUSTER_ID \
      cloudamqp_security_group_id=$CLOUDAMQP_SECURITY_GROUP_ID \
      db_database=$DB_DATABASE \
      db_password=$DB_PASSWORD \
      db_username=$DB_USERNAME \
      db_masterusername=$DB_MASTERUSERNAME \
      db_masterpassword=$DB_MASTERPASSWORD \
      elasticsearch_security_group_id=$ELASTICSEARCH_SECURITY_GROUP_ID \
      env=$ENV \
      ipcode=$IPCODE \
      private_security_group_id=$PRIVATE_SECURITY_GROUP_ID \
      private_subnet_0=$PRIVATE_SUBNET_0 \
      private_subnet_1=$PRIVATE_SUBNET_1 \
      public_subnet_0=$PUBLIC_SUBNET_0 \
      public_subnet_1=$PUBLIC_SUBNET_1 \
      region=$REGION \
      role=$ROLE_ARN \
      security_group_id=$SECURITY_GROUP_ID \
      web_security_group_id=$WEB_SECURITY_GROUP_ID
    "

    echo -e "Build complete.\nPlease, now, configure DNS and ELBs\n\nlove,\njames\nxoxo"
elif [[ "${BUILDOUT}" = 'install' ]]; then
    eval $(/tool/set_vars -m hosts -v "${VPC_NAME}" -c "${CLUSTER_ID}" )

    ansible-playbook -i /ansible_hosts "/playbooks/${MODE}/software.yml" --extra-vars " \
      all_hosts=$ALL_HOSTS \
      amqp_url=${RABBIT_USERNAME}:${RABBIT_PASSWORD}@${RABBIT_HOST}/${RABBIT_VHOST} \
      clusterid=$CLUSTER_ID \
      consul=$CONSUL \
      db_host=$DB_HOST \
      db_masterusername=$DB_MASTERUSERNAME \
      db_masterpassword=$DB_MASTERPASSWORD \
      db_password=$DB_PASSWORD \
      ipcode=$IPCODE \
      jar_version=$JAR_VERSION \
      job_nodes=$JOB_NODES \
      master_nodes=$MASTER_NODES \
      mongo_masterusername=$MONGO_MASTERUSERNAME \
      mongo_masterpassword=$MONGO_MASTERPASSWORD \
      domain=$DOMAIN \
      elasticsearch_nodes=$ELASTICSEARCH_NODES \
      mongo_config_nodes=$MONGO_CONFIG_NODES \
      mongo_router_nodes=$MONGO_ROUTER_NODES \
      mongo_shard_nodes=$MONGO_SHARD_NODES \
      consul_node_one=$(echo ${CONSUL_NODES} | awk -F, '{print $1}') \
      consul_node_two=$(echo ${CONSUL_NODES} | awk -F, '{print $2}') \
      consul_node_three=$(echo ${CONSUL_NODES} | awk -F, '{print $3}') \
      single_mongo_host=$(echo ${MONGO_ROUTER_NODES} | awk -F, '{print $1}') \
      ooyala_password=$OOYALA_PASSWORD \
      storage_nodes=$STORAGE_NODES
    "

    [[ "${MODE}" = 'infrastructure' ]] ||  /tool/configure_consul
fi
