#!/bin/bash
docker network create web
sed -i "s/email = \"\"/email = \"$EMAIL\"/g" traefik.toml
mkdir ./htdocs ./htdocs/download
docker-compose up -d