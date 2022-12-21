FROM ubuntu:22.04

RUN apt update

RUN apt install -qy nginx wget apache2-utils

RUN wget https://dist.ipfs.io/go-ipfs/v0.8.0/go-ipfs_v0.8.0_linux-amd64.tar.gz

RUN tar xvfz go-ipfs_v0.8.0_linux-amd64.tar.gz

RUN cd go-ipfs && bash install.sh

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000
EXPOSE 3001

CMD htpasswd -bc /.htpasswd $LOGIN $PASSWORD && \
    ./usr/sbin/nginx && \
    ipfs init --profile server || true && \
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]' && \
    ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]' && \
    ipfs config --json Swarm.ConnMgr.HighWater 100 && \
    ipfs config --json Swarm.ConnMgr.LowWater 50 && \
    ipfs daemon