# syntax=docker/dockerfile:1
FROM ubuntu:20.04

LABEL com.btmash.build-date="2024-06-24"

#stop asking geographic area while building image |  ¿apt-utils?  ¿unzip?
ARG DEBIAN_FRONTEND=noninteractive 

RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:git-core/ppa
RUN apt install -y \
    autoconf \
    apt-utils \
    build-essential \
    ca-certificates \
    pkg-config \
    wget \
    xvfb \
    curl \
    git \
    ssh-client \
    sudo \
    unzip \
    jq \
    tar

##### INSTALL DDEV STUFFS #####
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://pkg.ddev.com/apt/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/ddev.gpg > /dev/null
RUN chmod a+r /etc/apt/keyrings/ddev.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/ddev.gpg] https://pkg.ddev.com/apt/ * *" | tee /etc/apt/sources.list.d/ddev.list >/dev/null
RUN apt update
RUN apt install -y ddev

RUN groupadd -g 1000 ddev
RUN useradd -u 1000 -g 1000 ddev
RUN usermod -aG sudo ddev

##### INSTALL PHP STUFFS #####
RUN  apt-get install --no-install-recommends -y php7.4 php7.4-fpm php7.4-gd php7.4-cli php-pear php-redis php7.4-mysql php7.4-curl php-memcached php-bcmath php7.4-zip php-mbstring php7.4-dev
RUN php -- --disable-tls
RUN echo extension=timezonedb.so > /etc/php/7.4/mods-available/timezonedb.ini
RUN ln -s /etc/php/7.4/mods-available/timezonedb.ini /etc/php/7.4/cli/conf.d/30-timezone.ini
RUN ln -s /etc/php/7.4/mods-available/timezonedb.ini /etc/php/7.4/fpm/conf.d/30-timezone.ini

##### INSTALLING COMPOSER #####
RUN wget --no-check-certificate https://getcomposer.org/download/1.10.27/composer.phar
RUN chmod 0755 composer.phar && mv composer.phar /usr/local/bin/composer

RUN apt-get -y clean && apt-get -y autoremove

##### SWITCH TO NON-ROOT USER #####
RUN mkdir -p /opt/atlassian/bitbucketci/agent/build \
    && sed -i '/[ -z \"PS1\" ] && return/a\\ncase $- in\n*i*) ;;\n*) return;;\nesac' /root/.bashrc \
    && useradd --create-home --shell /bin/bash --uid 1000 pipelines
RUN usermod -aG sudo pipelines
RUN chown -R pipelines:pipelines /opt/atlassian/bitbucketci/agent/build

USER pipelines
RUN ls -lah
WORKDIR /opt/atlassian/bitbucketci/agent/build
ENTRYPOINT ["/bin/bash"]
