# docker-magento2

Opinionated Magento 2 docker image.

## Base image

 - Alpine 3.8

## Included software

 - NGINX
 - PHP 7.1 with FPM

## Extra bits

 - Node.js
 - Redis
 - Ruby
 - runit
 - sassc

## Getting started

```sh-session
# Build image
$ rake build

# Test image
# Visit http://localhost:3000/
$ rake test
```
