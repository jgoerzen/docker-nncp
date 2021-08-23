FROM jgoerzen/debian-base-security:bullseye
MAINTAINER John Goerzen <jgoerzen@complete.org>
RUN mv /usr/sbin/policy-rc.d.disabled /usr/sbin/policy-rc.d && \
    apt-get update && \
    apt-get -y -u dist-upgrade && \
    apt-get clean && \
    adduser --system --group --uid 5001 --disabled-password --disabled-login --shell /bin/bash --group nncp

ENV NNCP_VERSION 7.6.0
COPY service/*.service /etc/systemd/system/
COPY logrotate-nncp /etc/logrotate.d/local-nncp
COPY cron.daily/* /etc/cron.daily/
COPY sums /tmp

RUN set -x && \
    apt-get -y --no-install-recommends install golang ca-certificates && \
    cd /tmp && \
    wget http://www.nncpgo.org/download/nncp-$NNCP_VERSION.tar.xz && \
    sha256sum -c < sums && \
    tar -xf nncp-$NNCP_VERSION.tar.xz && \
    cd nncp-$NNCP_VERSION && \
    PREFIX=/usr/local ./contrib/do install && \
    cd /tmp && \
    rm -r /tmp/* && \
    dpkg --purge golang && \
    apt-get -y --purge autoremove && \
    apt-get clean && rm -rf /tmp/setup /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    systemctl enable nncp-daemon && \
    systemctl enable nncp-toss && \
    systemctl enable nncp-caller && \
    /usr/local/bin/docker-wipelogs && \
    mv /usr/sbin/policy-rc.d /usr/sbin/policy-rc.d.disabled

VOLUME ["/var/spool/uucp"]
EXPOSE 5400
CMD ["/usr/local/bin/boot-debian-base"]
