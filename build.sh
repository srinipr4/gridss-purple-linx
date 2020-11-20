#!/bin/bash
./package.sh
version=$(grep software.version Dockerfile | grep -oh '".*"' | tr -d \")
docker build --tag gridss/gridss-purple-linx:$version .
docker build --tag gridss/gridss-purple-linx:latest .
echo "docker push gridss/gridss-purple-linx:latest"
echo "docker push gridss/gridss-purple-linx:$version"

