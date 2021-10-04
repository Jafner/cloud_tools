#!/bin/bash
docker network create web
sed -i "s/email = \"\"/email = \"$EMAIL\"/g" traefik.toml
mkdir -p ./htdocs/download
touch acme.json 
chmod 600 acme.json
docker-compose up -d