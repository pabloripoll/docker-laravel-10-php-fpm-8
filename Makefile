# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Settings
C_BLU='\033[0;34m'
C_GRN='\033[0;32m'
C_RED='\033[0;31m'
C_YEL='\033[0;33m'
C_END='\033[0m'

include .env

DOCKER_TITLE=$(PROJECT_TITLE)

CURRENT_DIR=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(CURRENT_DIR))
ROOT_DIR=$(CURRENT_DIR)

help: ## shows this Makefile help message
	echo 'usage: make [target]'
	echo
	echo 'targets:'
	egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: hostname fix-permission host-check

hostname: ## shows local machine ip
	echo $(word 1,$(shell hostname -I))
	echo $(ip addr show | grep "\binet\b.*\bdocker0\b" | awk '{print $2}' | cut -d '/' -f 1)

fix-permission: ## sets project directory permission
	$(DOCKER_USER) chown -R ${USER}: $(ROOT_DIR)/

host-check: ## shows this project ports availability on local machine
	cd docker/nginx-php && $(MAKE) port-check

# -------------------------------------------------------------------------------------------------
#  Laravel Service
# -------------------------------------------------------------------------------------------------
.PHONY: laravel-ssh laravel-set laravel-create laravel-start laravel-stop laravel-destroy laravel-install laravel-update

laravel-ssh: ## enters the Laravel container shell
	cd docker/nginx-php && $(MAKE) ssh

laravel-set: ## sets the Laravel PHP enviroment file to build the container
	cd docker/nginx-php && $(MAKE) env-set

laravel-create: ## creates the Laravel PHP container from Docker image
	cd docker/nginx-php && $(MAKE) build up

laravel-start: ## starts the Laravel PHP container running
	cd docker/nginx-php && $(MAKE) start

laravel-stop: ## stops the Laravel PHP container but data won't be destroyed
	cd docker/nginx-php && $(MAKE) stop

laravel-destroy: ## removes the Laravel PHP from Docker network destroying its data and Docker image
	cd docker/nginx-php && $(MAKE) clear destroy

laravel-install: ## installs set version of Laravel into container
	cd docker/nginx-php && $(MAKE) app-install

laravel-update: ## updates set version of Laravel into container
	cd docker/nginx-php && $(MAKE) app-update

# -------------------------------------------------------------------------------------------------
#  Repository Helper
# -------------------------------------------------------------------------------------------------
repo-flush: ## clears local git repository cache specially to update .gitignore
	git rm -rf --cached .
	git add .
	git commit -m "fix: cache cleared for untracked files"
