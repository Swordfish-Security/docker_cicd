# Docker CI/CD security analysis
Integrating Docker scanning tools into CI/CD

This repository contains different approaches to utilize a set of tools for scanning various aspects of Docker security.
The pack could be integrated with different CI/CD procedures.

The set of tools consists of 
* Hadolint (https://github.com/hadolint/hadolint) - Dockerfile linter
* Dockle (https://github.com/goodwithtech/dockle) - Docker image linter
* Trivy (https://github.com/knqyf263/trivy/) - Light-weight CVE analyser for Docker images and dependencies
* Small Python script to combine all tools output in json and make a simple HTML report

The pack comes in three flavours:  
## GitLab CI/CD configuration YAML  
Purpose: to integrate Docker security tools into CI/CD process via GitLab  
You can import the YAML file into your test project, download sample Dockerfile and try the integration process.

## sh-script  
Purpose: to install and run all tools on a dedicated host (VM or whatever you like) via simple shell script  

First, make sure you have Docker installed and current user is in docker group
```
$ sudo apt-get install -y docker.io
$ sudo usermod -a -G docker $(whoami)
```
Then reconnect the terminal session.

## Dockerfiles  
Purpose: to build a Docker container with all the tools

Input includes a Dockerfile and the name of the image to scan  
Output is results.html report, containing all findings from all 3 tools

After you clone the repo and cd into it you can build Docker images for scanning using the following commands (tagged as "image"):
```
~/docker_cicd$ cd Dockerfile
./Dockerfile$ docker build -t dscan:image -f docker_security.df .
./Dockerfile$ cd ..
```
or if you would need to scan exported images in .tar form use another Dockerfile (tagged as "tar_file"):
```
~/docker_cicd$ cd Dockerfile_tar
./Dockerfile$ docker build -t dscan:tar_file -f docker_security.df .
./Dockerfile$ cd ..
```

After building images of the scanning tools you can run the scan like this:  
! Substitute $(pwd)/Dockerfile/docker_security.df for the absolute path to your Dockerfile to scan and specify the image:tag you want to scan in DOCKERIMAGE variable
```
~/docker_cicd$ docker run --rm -v $(pwd)/results:/results -v $(pwd)/Dockerfile/docker_security.df:/Dockerfile -e DOCKERIMAGE="python:3.5" dscan:image
```
or if you would need to scan exported images in .tar form - use an image tagged as "tar_file":
```
~/docker_cicd$ docker run --rm -v $(pwd)/results:/results -v $(pwd)/Dockerfile/docker_security.df:/Dockerfile -v $(pwd)/image_to_scan.tar:/image_to_scan.tar -e DOCKERIMAGE="image_to_scan.tar" dscan:tar_file
```

When the scanning is done you can find raw json results and humanified HTML results file in ./results folder.  

I would recommend rebuilding the docker image on a daily basis in a non-peak time to fetch Trivy databases. This is because CVE bases in Trivy are updated every now and then and running image will take less time as Trivy will not fetch the complete data (3+ Gb) each time you run a scan.
