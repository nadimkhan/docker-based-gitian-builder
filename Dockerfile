FROM ubuntu:trusty
MAINTAINER Nadim Khan <graphixcon@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /shared
RUN apt-get update && \
apt-get --no-install-recommends -yq install \
locales \
git-core \
build-essential \
ca-certificates \
ruby \
rsync && \
apt-get -yq purge grub > /dev/null 2>&1 || true && \
apt-get -y dist-upgrade && \
locale-gen en_US.UTF-8 && \
update-locale LANG=en_US.UTF-8 && \
bash -c '[[ -d /shared/gitian-builder ]] || git clone https://github.com/nadimkhan/gitian-builder /shared/gitian-builder' && \
useradd -d /home/ubuntu -m -s /bin/bash ubuntu && \
chown -R ubuntu.ubuntu /shared/ && \
chown root.root /shared/gitian-builder/target-bin/grab-packages.sh && \
chmod 755 /shared/gitian-builder/target-bin/grab-packages.sh && \
echo 'ubuntu ALL=(root) NOPASSWD:/usr/bin/apt-get,/shared/gitian-builder/target-bin/grab-packages.sh' > /etc/sudoers.d/ubuntu && \
chown root.root /etc/sudoers.d/ubuntu && \
chmod 0400 /etc/sudoers.d/ubuntu && \
chown -R ubuntu.ubuntu /home/ubuntu
USER ubuntu
RUN printf "[[ -d /shared/saviour ]] || \
git clone -b \$1 --depth 1 \$2 /shared/saviour && \
cd /shared/gitian-builder; \
./bin/gbuild --skip-image --commit saviour=\$1 --url saviour=\$2 \$3" > /home/ubuntu/runit.sh
CMD ["v2.0.0.0","https://github.com/puredev321/pure-v2.git","../saviour/contrib/gitian-descriptors/gitian-linux.yml"]
ENTRYPOINT ["bash", "/home/ubuntu/runit.sh"]
