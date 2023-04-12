#!/bin/bash
cd /home/ubuntu
mkdir jenkins_home
# sudo docker run -d -v jenkins_home:/home/ubuntu/jenkins_home -p 80:8080 -p 50000:50000 --restart=on-failure jenkins/jenkins:lts-jdk11

sudo docker network create jenkins
sudo docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume /home/ubuntu/jenkins_home:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2
sudo docker build -t jenkins-blueocean:2.395-jdk11-1 .
sudo docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 80:8080 --publish 50000:50000 \
  --volume /home/ubuntu/jenkins_home:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins-blueocean:2.395-jdk11-1