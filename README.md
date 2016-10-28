# vidi YO!

![yo!](https://media.giphy.com/media/JoYtQguJdpwiY/giphy.gif)

**LETS BUILD A ANSIBLE YO!**

This unholy mess of ruby, ansible and bash does all kinds of clustering and building for our flex configuration and projects.

## Testing the Ruby
You will need consul running locally on localhost:8500

```
$brew install consul
$consul agent -dev
```
rspec 

## Building!

```bash
$ docker build -t vidyo .
```

## Running!
```bash
$ docker run -ti -e CLUSTER_ID=test0  -v ~/etc/dev.env:/.env -v ~/secure/mnt/vault/keys:/keys -v ${PWD}/ansible:/playbooks vidyo
```

### Reference !!

vidi-YO! uses three volumes to control the build:

| mount      | purpose                                                  | sample value   | notes                                                                                                            |
|------------|----------------------------------------------------------|----------------|------------------------------------------------------------------------------------------------------------------|
| /keys      | contains credentials and ssh keys for the build          | ${HOME}/.aws   | uses same ini files as aws cli, but with the addition of the private key for the key pair you're connecting with |
| /playbooks | contains the playbooks and ansible goodies to build with | ${PWD}/ansible |                                                                                                                  |
| /.env      | a list of environment variables for the build. See below | ${HOME}/etc/env | file is sourced if it exists; prefer `export FOO=bar` format |


### Environment variables !!

vidi-YO! uses a series of environment variables to control stuff. These may either be loaded on the command line with `-e ` flags to `docker run` or stored in a file which is mounted at `/.env` in the container. If this file exists it will be sourced after default values are set as per:

```bash
[ -f /.env ] && source /.env
```

The following variables are set in `src/entry_point.sh`

```bash
: ${CLUSTER_ID:?}

: ${AMI:=ami-31328842}
: ${DB_DATABASE:=master}
: ${DB_PASSWORD:=iamsoVERYsmart}
: ${DB_USERNAME:=admin}
: ${DOMAIN:=master.dev.nativ-systems.com}
: ${ELASTICSEARCH_CLUSTERNAME:=elasticsearch}
: ${ENV:=t}
: ${IPCODE:=P386}
: ${MASTERUSER_PASSWORD:=masteruser}
: ${MONGO_DATABASE:=flex}
: ${MONGO_PASSWORD:=PlainTextYo!}
: ${MONGO_REPLICASET:=''}
: ${MONGO_USERNAME:=flex_user}
: ${RABBIT_HOST:=localhost}
: ${RABBIT_PASSWORD:=flex}
: ${RABBIT_USERNAME:=flex}
: ${RABBIT_VHOST:=flex}
: ${REGION:=eu-west-1}
: ${ROLE_NAME:=FTMioRole}
: ${SECURITY_GROUP_NAME:=ESR-Video-Test-VPC-Resources-SG}
: ${SMTP_REPLAY:=mail.ft.com}
: ${VPC_NAME:=ESR-Video-Test-VPC}

[ -f /.env ] && source /.env

: ${OOYALA_PASSWORD:?}
```

**Note:**

`OOYALA_PASSWORD` is the password docker uses to connect to registry.ooflex.net for docker images. This has to be set, but having it set to something at random will still allow the vast majority of tasks. You'll still be able to restart existing containers, build clusters, etc. - you just wont be able to pull latest versions.


# Wait... Really?

![real-life](http://www.theodo.fr/uploads/blog//2015/10/isthisreallife.gif)


## YEP!

![yo!](https://camo.githubusercontent.com/891c3108cdd79881a3e81dfc488888d3ad7e017b/687474703a2f2f692e696d6775722e636f6d2f3366716a534e4e2e676966)
