<div style="width:100%;float:left;clear:both;margin-bottom:50px;">
    <a href="https://github.com/pabloripoll?tab=repositories">
        <img style="width:150px;float:left;" src="https://pabloripoll.com/files/logo-light-100x300.png"/>
    </a>
</div>

# Docker Laravel 10 with PHP FPM 8+

The objective of this repository is having a CaaS [Containers as a Service](https://www.ibm.com/topics/containers-as-a-service) to provide a start up application with the basic enviroment features to deploy a php service running with Nginx and PHP-FPM in a container for [Laravel](https://laravel.com/) and another container with a MySQL database to follow the best practices on an easy scenario to understand and modify on development requirements.

The connection between container is as [Host Network](https://docs.docker.com/network/drivers/host/) on `eth0`, thus both containers do not share networking or bridge configuration.

As client end user both services can be accessed through `localhost:${PORT}` but the connection between containers is through the `${HOSTNAME}:${PORT}`.

### Laravel Docker Container Service

- [Laravel 10](https://laravel.com/docs/10.x/releases)

- [PHP-FPM 8.3](https://www.php.net/releases/8.3/en.php)

- [Nginx 1.24](https://nginx.org/)

- [Alpine Linux 3.19](https://www.alpinelinux.org/)

### Database Container Service

To connect this service to a SQL database, it can be used the following [MariaDB 10.11](https://mariadb.com/kb/en/changes-improvements-in-mariadb-1011/) service:
- [https://github.com/pabloripoll/docker-mariadb-10.11](https://github.com/pabloripoll/docker-mariadb-10.11)

### Project objetives with Docker

* Built on the lightweight and secure Alpine 3.19 [2024 release](https://www.alpinelinux.org/posts/Alpine-3.19.1-released.html) Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-40MB)
* Uses PHP 8.3 as default for the best performance, low CPU usage & memory footprint, but also can be downgraded till PHP 8.0
* Optimized for 100 concurrent users
* Optimized to only use resources when there's traffic (by using PHP-FPM's `on-demand` process manager)
* The services Nginx, PHP-FPM and supervisord run under a project-privileged user to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs
* Services independency to connect the application to other database allocation

#### PHP config

To use a different PHP 8 version the following [Dockerfile](docker/nginx-php/docker/Dockerfile) arguments and variable has to be modified:
```Dockerfile
ARG PHP_VERSION=8.3
ARG PHP_ALPINE=83
...
ENV PHP_V="php83"
```

Also, it has to be informed to [Supervisor Config](docker/nginx-php/docker/config/supervisord.conf) the PHP-FPM version to run.
```bash
...
[program:php-fpm]
command=php-fpm83 -F
...
```

#### Containers on Windows systems

This project has not been tested on Windows OS neither I can use it to test it. So, I cannot bring much support on it.

Anyway, using this repository you will needed to find out your PC IP by login as an `administrator user` to set connection between containers.

```bash
C:\WINDOWS\system32>ipconfig /all

Windows IP Configuration

 Host Name . . . . . . . . . . . . : 191.128.1.41
 Primary Dns Suffix. . . . . . . . : paul.ad.cmu.edu
 Node Type . . . . . . . . . . . . : Peer-Peer
 IP Routing Enabled. . . . . . . . : No
 WINS Proxy Enabled. . . . . . . . : No
 DNS Suffix Search List. . . . . . : scs.ad.cs.cmu.edu
```

Take the first ip listed. Wordpress container will connect with database container using that IP.

#### Containers on Unix based systems

Find out your IP on UNIX systems and take the first IP listed
```bash
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```

## Structure

Directories and main files on a tree architecture description
```
.
│
├── docker
│   └── nginx-php
│       ├── ...
│       ├── .env.example
│       └── docker-compose.yml
│
├── resources
│   ├── database
│   │   ├── laravel-init.sql
│   │   └── laravel-backup.sql
│   │
│   └── laravel
│       └── (any file or directory required for re-building the app...)
│
├── laravel
│   └── (application...)
│
├── .env
├── .env.example
└── Makefile
```

## Automation with Makefile

Makefiles are often used to automate the process of building and compiling software on Unix-based systems as Linux and macOS.

*On Windows - I recommend to use Makefile: \
https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows*

Makefile recipies
```bash
$ make help
usage: make [target]

targets:
Makefile  help                   shows this Makefile help message
Makefile  hostname               shows local machine ip
Makefile  fix-permission         sets project directory permission
Makefile  host-check             shows this project ports availability on local machine
Makefile  laravel-ssh            enters the Laravel container shell
Makefile  laravel-set            sets the Laravel PHP enviroment file to build the container
Makefile  laravel-create         creates the Laravel PHP container from Docker image
Makefile  laravel-start          starts the Laravel PHP container running
Makefile  laravel-stop           stops the Laravel PHP container but data will not be destroyed
Makefile  laravel-destroy        removes the Laravel PHP from Docker network destroying its data and Docker image
Makefile  laravel-install        installs set version of Laravel into container
Makefile  laravel-update         updates set version of Laravel into container
Makefile  repo-flush             clears local git repository cache specially to update .gitignore
```

## Service Configuration

Create a [DOTENV](.env) file from [.env.example](.env.example) and setup according to your project requirement the following variables
```
# REMOVE COMMENTS WHEN COPY THIS FILE

# Leave it empty if no need for sudo user to execute docker commands
DOCKER_USER=sudo

# Container data for docker-compose.yml
PROJECT_TITLE="Laravel"   # <- this name will be prompt for Makefile recipes
PROJECT_ABBR="laravel"    # <- part of the service image tag - useful if similar services are running

# Laravel container
PROJECT_HOST="127.0.0.1"                    # <- for this project is not necessary
PROJECT_PORT="8888"                         # <- port access container service on local machine
PROJECT_CAAS="laravel-app"                  # <- container as a service name to build service
PROJECT_PATH="../../../laravel"             # <- path where application is binded from container to local
PROJECT_DB_PATH="../../resources/database/" # <- path where database backup or copy resides
```

Exacute the following command to create the [docker/.env](docker/.env) file, required for building the container
```bash
$ make laravel-set
Laravel docker-compose.yml .env file has been set.
```

Checkout port availability from enviroment set
```bash
$ make host-check

Checking configuration for Laravel container:
Laravel > port:8888 is free to use.
```

Checkout local machine IP to set connection between container services using the following makefile recipe if required
```bash
$ make hostname

192.168.1.41
```

## Create the Container Service

```bash
$ make laravel-create

LARAVEL docker-compose.yml .env file has been set.

[+] Building 54.3s (26/26) FINISHED                                                 docker:default
=> [nginx-php internal] load build definition from Dockerfile                       0.0s
 => => transferring dockerfile: 2.78kB                                              0.0s
 => [nginx-php internal] load metadata for docker.io/library/composer:latest        1.5s
 => [nginx-php internal] load metadata for docker.io/library/php:8.3-fpm-alpine     1.5s
 => [nginx-php internal] load .dockerignore                                         0.0s
 => => transferring context: 108B                                                   0.0s
 => [nginx-php internal] load build context                                         0.0s
 => => transferring context: 8.30kB                                                 0.0s
 => [nginx-php] FROM docker.io/library/composer:latest@sha256:63c0f08ca41370...
...
 => [nginx-php] exporting to image                                                  1.0s
 => => exporting layers                                                             1.0s
 => => writing image sha256:3c99f91a63edd857a0eaa13503c00d500fad57cf5e29ce1d...     0.0s
 => => naming to docker.io/library/laravel-app:laravel-nginx-php                    0.0s
[+] Running 1/2
 ⠴ Network laravel-app_default  Created                                             0.4s
 ✔ Container laravel-app        Started                                             0.3s
[+] Running 1/0
 ✔ Container laravel-app        Running
```

If container service has been built with the application content completed, accessing by browsing [http://localhost:8888/](http://localhost:8888/) will display the successful installation welcome page.

If container has been built without application, the following Makefile recipe will install the application that is configure in [docker/nginx-php/Makefile](docker/nginx-php/Makefile) service
```bash
$ make laravel-install
```

If container has been built with the application copy from repository, the following Makefile recipe will update the application dependencies
```bash
$ make laravel-update
```

## Container Information

Running container on Docker
```bash
$ sudo docker ps -a
CONTAINER ID   IMAGE      COMMAND    CREATED      STATUS      PORTS                                             NAMES
ecd27aeae010   lara...    "docker-php-entrypoi…"  1 min...    9000/tcp, 0.0.0.0:8888->80/tcp, :::8888->80/tcp   laravel-app
```

Docker image size
```bash
$ sudo docker images
REPOSITORY   TAG           IMAGE ID       CREATED         SIZE
laravel-app  lara...       373f6967199b   5 minutes ago   251MB
```

Stats regarding the amount of disk space used by the container
```bash
$ sudo docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          1         1         251.4MB   0B (0%)
Containers      1         1         4B        0B (0%)
Local Volumes   1         0         117.9MB   117.9MB (100%)
Build Cache     39        0         10.56kB   10.56kB
```

## Stopping the Container Service

Using the following Makefile recipe stops application from running, keeping database persistance and application files binded without any loss
```bash
$ make laravel-stop
[+] Stopping 1/1
 ✔ Container laravel-app  Stopped                                                    0.5s
```

## Removing the Container Image

To remove application container from Docker network use the following Makefile recipe *(Docker prune commands still needed to be applied manually)*
```bash
$ make laravel-destroy

[+] Removing 1/0
 ✔ Container laravel-app  Removed                                                     0.0s
[+] Running 1/1
 ✔ Network laravel-app_default  Removed                                               0.4s
Untagged: laravel-app:laravel-nginx-php
Deleted: sha256:3c99f91a63edd857a0eaa13503c00d500fad57cf5e29ce1da3210765259c35b1
```

Information on pruning Docker system cache
```bash
$ sudo docker system prune

...
Total reclaimed space: 168.4MB
```

Information on pruning Docker volume cache
```bash
$ sudo docker system prune

...
Total reclaimed space: 0MB
```

## Laravel Service Check

There are two PHP files on [resources/laravel](resources/laravel) with same structure as application to replace or add a predifined example to test the service.

It can be used an API platform service *(Postman, Firefox RESTClient, etc..)* or just browsing the following endpoints to check connection with Laravel.

Check-out a basic service check
```
GET: http://localhost:8888/api/v1/health

{
    "status": true
}
```

Check connection to database through this endpoint. If conenction params are not set already or does not exist, endpoint response will be as follow
```
GET: http://localhost:8888/api/v1/health/db

{
    "status": false,
    "message": "Connect to database failed - Check connection params.",
    "error": {
        "errorInfo": [
            "HY000",
            2002,
            "Host is unreachable"
        ]
    }
}
```

Open [laravel/.env](laravel/.env) file and set the selected database type connection params.

It can be used the repository: [https://github.com/pabloripoll/docker-mariadb-10.11](https://github.com/pabloripoll/docker-mariadb-10.11)

Complete the MySQL database connection params. Use local hostname IP `$ make hostname` to set `DB_HOST` variable
```
DB_CONNECTION=mysql
DB_HOST=192.168.1.41
DB_PORT=
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=
```

Checking the connection to database once is set correctly will response as follows
```
GET: http://localhost:8888/api/v1/health/db

{
    "status": true
}
```