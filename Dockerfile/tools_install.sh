#!/bin/bash
export TRIVYCACHE="/.trivy_cache"

# installing all necessary stuff
echo "[+] Installing required packages"
apt-get update
apt-get install -y rpm wget git python3 python3-pip

# preparing directory structure
echo "[+] Preparing necessary directories"
mkdir docker_tools
cd docker_tools
mkdir $TRIVYCACHE
mkdir $ARTIFACT_FOLDER

# Hadolint
echo "[+] Fetching Hadolint"
export VERSION=$(wget -q -O - https://api.github.com/repos/hadolint/hadolint/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -nv --no-cache https://github.com/hadolint/hadolint/releases/download/v${VERSION}/hadolint-Linux-x86_64 -O hadolint-Linux-x86_64 && chmod +x hadolint-Linux-x86_64

# Dockle
echo "[+] Fetching Dockle"
export VERSION=$(wget -q -O - https://api.github.com/repos/goodwithtech/dockle/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -nv --no-cache https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.tar.gz -O dockle_Linux-64bit.tar.gz && tar zxf dockle_Linux-64bit.tar.gz

# Trivy
echo "[+] Fetching Trivy"
export VERSION=$(wget -q -O - https://api.github.com/repos/knqyf263/trivy/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -nv --no-cache https://github.com/knqyf263/trivy/releases/download/v${VERSION}/trivy_${VERSION}_Linux-64bit.tar.gz -O trivy_Linux-64bit.tar.gz && tar zxf trivy_Linux-64bit.tar.gz

echo "[+] Fetching Trivy DB"
./trivy --refresh -q --cache-dir $TRIVYCACHE

# cleaning up
echo "[+] Removing left-overs"
rm *.tar.gz LICENSE README.md 

# HTML results from all tools outputs
echo "[+] Fetching json2HTML"
pip3 install json2html
wget -nv --no-cache -O convert_json_results.py https://raw.githubusercontent.com/shad0wrunner/docker_cicd/master/convert_json_results.py

# Collect the results in docker_tools/results.html
echo "[+] Image has been built"