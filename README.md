# docker-magento2

[![Docker Automated build](https://img.shields.io/docker/automated/delegator/magento2.svg?style=flat-square)](https://hub.docker.com/r/delegator/magento2/)

Opinionated Magento 2 docker image.

## Base image

 - Alpine 3.8

## Included software

 - nginx
 - PHP 7.1 with FPM

## Extra bits

 - Node.js
 - Redis
 - runit
 - sassc
 - dockerize

## Getting started

```sh-session
# Build image
$ rake build

# Test image
# Visit http://localhost:3000/
$ rake test
```
