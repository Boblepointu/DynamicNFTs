FROM ubuntu:22.04

RUN apt update

RUN apt install -qy nginx wget apache2-utils

RUN wget https://dist.ipfs.io/go-ipfs/v0.8.0/go-ipfs_v0.8.0_linux-amd64.tar.gz

RUN tar xvfz go-ipfs_v0.8.0_linux-amd64.tar.gz

RUN cd go-ipfs && bash install.sh

COPY ./nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD htpasswd -bc /.htpasswd $LOGIN $PASSWORD && ./usr/sbin/nginx && ipfs init && ipfs daemon