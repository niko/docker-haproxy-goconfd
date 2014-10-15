FROM ubuntu:trusty
RUN apt-get -y update
ENV DEBIAN_FRONTEND noninteractive

RUN \
  sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y psmisc curl haproxy=1.5.3-1~ubuntu14.04.1 && \
  sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy && \
  rm -rf /var/lib/apt/lists/*

ADD haproxy-start.bash /haproxy-start

ADD haproxy.cfg.template /haproxy.cfg.template

CMD ["/haproxy-start"]

# To run:
#$ docker run -p 80:80 -p 11443:11443 -p 6380:6380 -i -t haproxy
# 
# Even more convinient: use the run-docker-haproxy wrapper script to automatically expose the right ports.
