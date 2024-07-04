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
  find src -mindepth 1 -maxdepth 1 ! -name 'patch' ! -name 'gperftools-2.9.1.tar.gz' ! -name 'icu4c-60_3-src.tgz' ! -name 'jemalloc-5.3.0.tar.bz2' ! -name 'libunwind-1.2.1.tar.gz' ! -name 'p.tar.gz' ! -path 'src/patch/*' -exec rm -rf {} +

VOLUME ["/home/wwwroot", "/home/wwwlogs", "/usr/local/nginx/conf"]

EXPOSE 80 443 3306

CMD ["/sbin/init"]