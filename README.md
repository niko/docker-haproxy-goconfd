docker-haproxy-goconfd
======================

A docker container and wrapper script to use haproxy for routing between services. Uses https://github.com/niko/goconfd for configuration.

This in an example for using goconfd to configure a haproxy for network routing between docker containers.

Basic concept:

* run a dns server on each docker host to make *.service domains resolve to the docker host.
* run haproxy on each docker host to route the network to the right service on this or other hosts.
* make all http services use port 80 and route according to the host header.
* expose selected backends to the world via port 80.
