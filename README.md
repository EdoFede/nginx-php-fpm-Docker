# Docker nginx & PHP-FPM base image
A base image with nginx web server and PHP-FPM.

[![](https://images.microbadger.com/badges/image/edofede/nginx-php-fpm.svg)](https://microbadger.com/images/edofede/nginx-php-fpm "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/edofede/nginx-php-fpm.svg)](https://github.com/EdoFede/nginx-php-fpm-Docker/releases)
[![](https://img.shields.io/docker/pulls/edofede/nginx-php-fpm.svg)](https://hub.docker.com/r/edofede/nginx-php-fpm)  
[![](https://img.shields.io/github/last-commit/EdoFede/nginx-php-fpm-Docker.svg)](https://github.com/EdoFede/nginx-php-fpm-Docker/commits/master)
[![Build Status](https://travis-ci.com/EdoFede/nginx-php-fpm-Docker.svg?branch=master)](https://travis-ci.com/EdoFede/nginx-php-fpm-Docker)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/414ece2ddcda4705896906beb713dc50)](https://www.codacy.com/app/EdoFede/nginx-php-fpm-Docker?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=EdoFede/nginx-php-fpm-Docker&amp;utm_campaign=Badge_Grade)  
[![](https://img.shields.io/github/license/EdoFede/nginx-php-fpm-Docker.svg)](https://github.com/EdoFede/BaseImage-Docker/blob/master/LICENSE)
[![](https://img.shields.io/badge/If%20you%20can%20read%20this-you%20don't%20need%20glasses-brightgreen.svg)](https://shields.io)

## Introduction
This Docker image is based top of [my Alpine base image](https://hub.docker.com/r/edofede/baseimage) and it's basically a ready-to-run nginx + PHP-FPM web server.  

## Multi-Architecture
This image is built with multiple CPU architecture support.  
As stated in Docker best-practice, the image is tagged and released with current version tag for many cpu architectures and a manifest "general" version tag, which automatically points to the right architecture when you use the image.

I also add the "latest" manifest tag every time I release a new version.

## How to use
### Use as base image
The image is available on the Docker hub and can be used as base image to build your own Web project or Web-app.

```Dockerfile
FROM edofede/nginx-php-fpm:<VERSION>
```

### Container creation
You can simply create and start a Docker container from the [image on the Docker hub](https://hub.docker.com/r/edofede/nginx-php-fpm) by running:

```bash
docker create --name nginx-php-fpm edofede/nginx-php-fpm:latest
docker start nginx-php-fpm
```
Then you can launch bash or other commands inside:

```bash
docker exec -ti nginx-php-fpm bash
```

If, instead, you want to run the image one-shot, without starting Web services, use:

```bash
docker run -ti --rm edofede/nginx-php-fpm:latest bash
```

### Entrypoint
The entrypoint script (``` /entrypoint.sh ```) accepts arguments. These are launched on the container, **instead** of starting runit and related services (nginx and PHP-FPM are not started if you pass arguments via the entrypoint).

## Setup
...to be completed...

### Set timezone
The image comes with tzdata already installed (and timzone setted to Europe/Rome).
To set a new timezone, launch a bash command and follow [this guide](https://wiki.alpinelinux.org/wiki/Setting_the_timezone) (skip the first command).

## Support me
I treat these free projects exactly like professional works and I'm glad to share it, with some of my knowledge, for free.

If you found my work useful and want to support me, you can donate me a little amount  
[![Donate](https://img.shields.io/badge/Donate-Paypal-2997D8.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=JA8LPLG38EVK2&source=url)
