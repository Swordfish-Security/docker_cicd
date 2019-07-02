#!/bin/bash
echo "[+] Setting environment variables"
export SHOWSTOPPER_PRIORITY="CRITICAL"
export TRIVYCACHE="/.trivy_cache"
export ARTIFACT_FOLDER="json"

cd docker_tools
mkdir $ARTIFACT_FOLDER

# Hadolint
echo "[+] Running Hadolint"
./hadolint-Linux-x86_64 -f json /Dockerfile > $ARTIFACT_FOLDER/hadolint_results.json

# Dockle
echo "[+] Running Dockle"
./dockle --exit-code 1 -f json --output $ARTIFACT_FOLDER/dockle_results.json --input /$DOCKERIMAGE

# Trivy
echo "[+] Running Trivy"
./trivy --auto-refresh --clear-cache --cache-dir $TRIVYCACHE -f json -o $ARTIFACT_FOLDER/trivy_results.json --exit-code 0 --quiet --input /$DOCKERIMAGE
./trivy --auto-refresh --cache-dir $TRIVYCACHE --exit-code 1 --severity $SHOWSTOPPER_PRIORITY --quiet --input /$DOCKERIMAGE

# HTML results from all tools outputs
echo "[+] Making the output look pretty"
python3 ./convert_json_results.py
mv $ARTIFACT_FOLDER/*.json /results
mv results.html /results

# Collect the results in docker_tools/results.html
echo "[+] Everything is done. Find the resulting HTML report in results.html"