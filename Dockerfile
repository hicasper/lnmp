FROM debian:bullseye-slim

ARG AUTOCMD

COPY . /root/lnmp

RUN set -ex && \
  apt-get update && \
  cd /root/lnmp && \
  echo $AUTOCMD | base64 -d > docker-inst.sh && \
  bash docker-inst.sh && \
  apt-get install -y sysvinit-core --no-install-recommends && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /root/lnmp/src/*-*

VOLUME ["/home/wwwroot", "/home/wwwlogs", "/usr/local/mysql/var", "/usr/local/nginx/conf", "/etc/my.cnf.d"]

EXPOSE 80 443 3306

CMD ["/sbin/init"]