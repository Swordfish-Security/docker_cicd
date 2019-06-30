#!/bin/bash
export DOCKERFILE="mydockerfile.df"
export DOCKERIMAGE="cloudinsky/cve-2017-5638"
export SHOWSTOPPER_PRIORITY="CRITICAL"
export TRIVYCACHE=".trivy_cache"
export ARTIFACT_FOLDER="json"

# installing all necessary stuff
sudo apt-get update
sudo apt-get install -y python3 python3-pip docker.io

# preparing directory structure
mkdir docker_tools
cd docker_tools
mkdir $TRIVYCACHE
mkdir $ARTIFACT_FOLDER

# fetching sample Dockerfile
wget -O mydockerfile.df https://raw.githubusercontent.com/shad0wrunner/docker_cicd/master/mydockerfile.df

# Hadolint
export VERSION=$(wget -q -O - https://api.github.com/repos/hadolint/hadolint/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget https://github.com/hadolint/hadolint/releases/download/v${VERSION}/hadolint-Linux-x86_64 -O hadolint-Linux-x86_64 && chmod +x hadolint-Linux-x86_64
./hadolint-Linux-x86_64 -f json $DOCKERFILE > $ARTIFACT_FOLDER/hadolint_results.json

# Dockle
export VERSION=$(wget -q -O - https://api.github.com/repos/goodwithtech/dockle/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.tar.gz -O dockle_Linux-64bit.tar.gz && tar zxf dockle_Linux-64bit.tar.gz
./dockle --exit-code 1 -f json --output $ARTIFACT_FOLDER/dockle_results.json $DOCKERIMAGE

# Trivy
export VERSION=$(wget -q -O - https://api.github.com/repos/knqyf263/trivy/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget https://github.com/knqyf263/trivy/releases/download/v${VERSION}/trivy_${VERSION}_Linux-64bit.tar.gz -O trivy_Linux-64bit.tar.gz && tar zxf trivy_Linux-64bit.tar.gz

./trivy --auto-refresh --clear-cache --cache-dir $TRIVYCACHE -f json -o $ARTIFACT_FOLDER/trivy_results.json --exit-code 0 --quiet $DOCKERIMAGE
./trivy --auto-refresh --cache-dir $TRIVYCACHE --exit-code 1 --severity $SHOWSTOPPER_PRIORITY --quiet $DOCKERIMAGE

# cleaning up
rm *.tar.gz LICENSE README.md 

# HTML results from all tools outputs
pip3 install json2html
wget -O convert_json_results.py https://raw.githubusercontent.com/shad0wrunner/docker_cicd/master/convert_json_results.py
python3 ./convert_json_results.py

# Collect the results in docker_tools/results.html