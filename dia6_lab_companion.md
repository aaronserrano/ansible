# Dia 6 - Laboratorios

## Pull imagen docker centos 7

```text
docker pull centos:7
```

## Push a Docker Hub

```text
$ export DOCKER_ID_USER="username"
$ docker login
$ docker tag my_image $DOCKER_ID_USER/my_image
$ docker push $DOCKER_ID_USER/my_image
```

Validar que se ve 



## Instalación docker compose

```
curl -L https://github.com/docker/compose/releases/download/1.17.0-rc1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```


## Voting app

```text
https://github.com/dockersamples/example-voting-app
```

```text
git clone https://github.com/dockersamples/example-voting-app.git
cd example-voting-app
docker-compose up

```