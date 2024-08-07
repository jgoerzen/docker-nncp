FROM jgoerzen/debian-base-security:bookworm
MAINTAINER John Goerzen <jgoerzen@complete.org>
RUN mv /usr/sbin/policy-rc.d.disabled /usr/sbin/policy-rc.d && \
    apt-get update && \
    apt-get -y -u dist-upgrade && \
    apt-get clean && \
    adduser --system --group --uid 5001 --disabled-password --disabled-login \
            --home /var/spool/nncp --shell /bin/bash --group nncp

### DON'T FORGET TO UPDATE CI WITH THE NEW VERSION WHEN CHANGING THIS!
### Also sums.
ENV NNCP_VERSION 8.11.0
COPY service/*.service /etc/systemd/system/
COPY logrotate-nncp /etc/logrotate.d/local-nncp
COPY cron.daily/* /etc/cron.daily/
COPY sums /tmp
COPY preinit /usr/local/preinit

RUN set -x && \
    apt-get -y --no-install-recommends install ca-certificates info && \
    apt-get -y --no-install-recommends -t bookworm-backports install golang-go && \
    cd /tmp && \
    wget https://nncp.mirrors.quux.org/download/nncp-$NNCP_VERSION.tar.xz && \
    sha256sum -c < sums && \
    tar -xf nncp-$NNCP_VERSION.tar.xz && \
    cd nncp-$NNCP_VERSION && \
    PREFIX=/usr/local ./bin/build && \
    PREFIX=/usr/local ./install && \
    cd /tmp && \
    rm -r /tmp/* && \
    apt-get -y --purge remove 'golang*' && \
    apt-get -y --purge autoremove && \
    apt-get clean && rm -rf /tmp/setup /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    systemctl enable nncp-daemon && \
    systemctl enable nncp-toss && \
    systemctl enable nncp-caller && \
    /usr/local/bin/docker-wipelogs && \
    mv /usr/sbin/policy-rc.d /usr/sbin/policy-rc.d.disabled && \
    chown nncp:nncp /var/spool/nncp

VOLUME ["/var/spool/nncp"]
EXPOSE 5400
CMD ["/usr/local/bin/boot-debian-base"]
