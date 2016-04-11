# vidi YO!

![yo!](https://media.giphy.com/media/JoYtQguJdpwiY/giphy.gif)

**LETS BUILD A ANSIBLE YO!**

## Building!

```bash
$ docker build -t vidyo .
```

## Running!
```bash
$ docker docker run -ti -e CLUSTER_ID=jspc0 -v ~/secure/mnt/vault/keys:/keys -v ${PWD}/ansible:/playbooks vidyo
```

### Reference

vidi-YO! uses two volumes to control the build:

| mount      | purpose                                                  | sample value   | notes                                                                                                            |
|------------|----------------------------------------------------------|----------------|------------------------------------------------------------------------------------------------------------------|
| /keys      | contains credentials and ssh keys for the build          | ${HOME}/.aws   | uses same ini files as aws cli, but with the addition of the private key for the key pair you're connecting with |
| /playbooks | contains the playbooks and ansible goodies to build with | ${PWD}/ansible |                                                                                                                  |


## Wait... Really?

![real-life](http://www.theodo.fr/uploads/blog//2015/10/isthisreallife.gif)


## YEP!

![yo!](https://camo.githubusercontent.com/891c3108cdd79881a3e81dfc488888d3ad7e017b/687474703a2f2f692e696d6775722e636f6d2f3366716a534e4e2e676966)
