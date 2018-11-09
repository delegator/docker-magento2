# docker-magento2

[![Docker Automated build](https://img.shields.io/docker/automated/delegator/magento2.svg?style=flat-square)](https://hub.docker.com/r/delegator/magento2/)

Opinionated Magento 2 docker image.

## Base image

 - Alpine 3.8

## Included software

 - nginx
 - PHP 7.1 with FPM
 - Redis
 - MySQL client
 - msmtp, aliased as sendmail

## Extra bits

 - Node.js
 - runit
 - sassc
 - dockerize

## Getting started

```sh-session
# Build image
docker build -t delegator/magento2 .

# Test image, visit http://magento2.local/
cd /path/to/magento2/project
docker run --init --rm -p 80:80 -v $(pwd)/var/www/magento2 delegator/magento2
```
