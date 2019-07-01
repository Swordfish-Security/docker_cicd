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
2. sh-script to install and run all tools on a dedicated host (VM or whatever you like)
3. Dockerfile to build a Docker container with all the tools

Input includes a Dockerfile and the name of the image to scan
Output is results.html report, containing all findings from all 3 tools


