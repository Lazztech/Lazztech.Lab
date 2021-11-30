# Jenkins

## Docker in Docker
The fist challenge is related to docker being depricated and replaced by OCI container runtimes like containerd in k3s. This means that there's no docker socket for jenkins to spin up docker build agents in. This is where "Docker in Docker" or dind comes into play.
- https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/

- https://hub.docker.com/_/docker
- https://hub.docker.com/r/jpetazzo/dind/
- https://hub.docker.com/r/gitlab/dind/
- https://github.com/jenkinsci/kubernetes-plugin/blob/master/examples/dind.groovy
- https://applatix.com/case-docker-docker-kubernetes-part/
- https://applatix.com/case-docker-docker-kubernetes-part-2/
- https://joostvdg.github.io/jenkins-pipeline/podtemplate-dind/
- https://itnext.io/jenkins-running-workers-in-kubernetes-and-docker-images-build-83299a10f3ca

DIND needs access to var/jenkins_home volume
- https://github.com/eldada/jenkins-in-kubernetes/issues/2
- https://github.com/eldada/jenkins-in-kubernetes/pull/4

Networking Issue related to docker in docker in kubernetes:
- https://github.com/gliderlabs/docker-alpine/issues/307
- https://liejuntao001.medium.com/fix-docker-in-docker-network-issue-in-kubernetes-cc18c229d9e5