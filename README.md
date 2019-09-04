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
1. GitLab CI/CD configuration YAML
[In progress] 2. sh-script to install and run all tools on a dedicated host (VM or whatever you like)
2.1. Make sure you have Docker installed and current user is in docker group
```
$ sudo apt-get install -y docker.io
$ sudo usermod -a -G docker $(whoami)
```
Then reconnect the terminal session.

[In progress] 3. Dockerfile to build a Docker container with all the tools

Input includes a Dockerfile and the name of the image to scan
Output is results.html report, containing all findings from all 3 tools

You can build Docker images using the following commands:
```
$ cd Dockerfile
$ docker build -t dscan:image -f docker_security.df .
```
or if you would need to scan exported images in .tar form use another Dockerfile:
```
$ cd Dockerfile_tar
$ docker build -t dscan:tar_file -f docker_security_tar.df .
```

After building an image you can run the scan like this:
Substitute $(pwd)/Dockerfile/docker_security.df for the path to your Dockerfile to scan and specify the image and the tag you want to scan in DOCKERIMAGE variable
```
$ mkdir results
$ docker run --rm -v $(pwd)/results:/results -v $(pwd)/Dockerfile/docker_security.df:/Dockerfile -e DOCKERIMAGE="python:3.5" dscan:image
```
or if you would need to scan exported images in .tar form:
```
$ mkdir results
$ docker run --rm -v $(pwd)/results:/results -v $(pwd)/Dockerfile/docker_security.df:/Dockerfile -v $(pwd)/image_to_scan.tar:/image_to_scan.tar -e DOCKERIMAGE="image_to_scan.tar" dscan:tar_file
```
I would recommend rebuilding the image on a daily basis because CVE bases in Trivy are updated every now and then and running image will take less time because Trivy will not fetch the new data (3+ Gb) each time.
