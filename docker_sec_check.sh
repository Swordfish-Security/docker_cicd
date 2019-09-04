#!/bin/bash
#
# Make sure Docker is installed and current user is a member of docker group ($groups)
# sudo apt-get install docker.io && sudo usermod -a -G docker $(whoami)
#
echo "[+] Setting environment variables"
export DOCKERFILE="Dockerfile"
export DOCKERIMAGE="bkimminich/juice-shop"
export SHOWSTOPPER_PRIORITY="CRITICAL"
export TRIVYCACHE=".trivy_cache"
export ARTIFACT_FOLDER="json"

# installing all necessary stuff
echo "[+] Installing required packages"
sudo apt-get update
sudo apt-get install -y python3 python3-pip rpm git

# preparing directory structure
echo "[+] Preparing necessary directories"
mkdir docker_tools
cd docker_tools
mkdir $TRIVYCACHE
mkdir $ARTIFACT_FOLDER

# fetching sample Dockerfile and image
echo "[+] Fetching sample Dockerfile"
wget -O $DOCKERFILE https://raw.githubusercontent.com/shad0wrunner/docker_cicd/master/mydockerfile.df

echo "[+] Pulling image to scan"
docker pull $DOCKERIMAGE

# Hadolint
echo "[+] Running Hadolint"
export VERSION=$(wget -q -O - https://api.github.com/repos/hadolint/hadolint/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -nv --no-cache https://github.com/hadolint/hadolint/releases/download/v${VERSION}/hadolint-Linux-x86_64 -O hadolint-Linux-x86_64 && chmod +x hadolint-Linux-x86_64
./hadolint-Linux-x86_64 -f json $DOCKERFILE > $ARTIFACT_FOLDER/hadolint_results.json

# Dockle
echo "[+] Running Dockle"
export VERSION=$(wget -q -O - https://api.github.com/repos/goodwithtech/dockle/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -nv --no-cache https://github.com/goodwithtech/dockle/releases/download/v${VERSION}/dockle_${VERSION}_Linux-64bit.tar.gz -O dockle_Linux-64bit.tar.gz && tar zxf dockle_Linux-64bit.tar.gz
./dockle --exit-code 1 -f json --output $ARTIFACT_FOLDER/dockle_results.json $DOCKERIMAGE

# Trivy
echo "[+] Running Trivy"
export VERSION=$(wget -q -O - https://api.github.com/repos/knqyf263/trivy/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -nv --no-cache https://github.com/knqyf263/trivy/releases/download/v${VERSION}/trivy_${VERSION}_Linux-64bit.tar.gz -O trivy_Linux-64bit.tar.gz && tar zxf trivy_Linux-64bit.tar.gz

./trivy --auto-refresh --clear-cache --cache-dir $TRIVYCACHE -f json -o $ARTIFACT_FOLDER/trivy_results.json --exit-code 0 --quiet $DOCKERIMAGE
./trivy --auto-refresh --cache-dir $TRIVYCACHE --exit-code 1 --severity $SHOWSTOPPER_PRIORITY --quiet $DOCKERIMAGE

# cleaning up
echo "[+] Removing left-overs"
rm *.tar.gz LICENSE README.md 

# HTML results from all tools outputs
echo "[+] Making the output look pretty"
pip3 install json2html
wget -nv --no-cache -O convert_json_results.py https://raw.githubusercontent.com/shad0wrunner/docker_cicd/master/convert_json_results.py
python3 ./convert_json_results.py

# Collect the results in docker_tools/results.html
echo "[+] Everything is done. Find the resulting HTML report in results.html"
