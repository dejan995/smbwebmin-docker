FROM ubuntu:bionic

ENV DEBIAN_FRONTEND noninteractive
ENV WEBMIN_VERSION 1.941

RUN apt update && apt install -y curl tar perl libnet-ssleay-perl libauthen-pam-perl expect tzdata supervisor samba && \
    mkdir /opt/webmin && curl -sSL https://sourceforge.net/projects/webadmin/files/webmin/${WEBMIN_VERSION}/webmin-${WEBMIN_VERSION}.tar.gz/download | tar xz -C /opt/webmin --strip-components=1 && \
    mkdir -p /var/webmin/ && \
    ln -s /dev/stdout /var/webmin/miniserv.log && \
    ln -s /dev/stderr /var/webmin/miniserv.error

COPY /scripts/entrypoint.sh /
COPY /scripts/supervisord.conf /

ENV nostart=true
ENV nouninstall=true
ENV noportcheck=true
ENV ssl=0
ENV login=admin
ENV password=admin
ENV atboot=false
ENV nochown=true

RUN  /opt/webmin/setup.sh && \
     sed -e 's/^start_cmd=.*/start_cmd=supervisorctl start smbd nmbd/g' -e 's/^restart_cmd=.*/restart_cmd=supervisorctl restart smbd nmbd/g' -e 's/^stop_cmd=.*/stop_cmd=supervisorctl stop smbd nmbd/g' -i /etc/webmin/samba/config && \
     chmod +x entrypoint.sh

VOLUME /etc/webmin/
VOLUME /etc/samba/
VOLUME /var/lib/samba/

EXPOSE 10000

EXPOSE 137/udp
EXPOSE 138/udp
EXPOSE 139
EXPOSE 445

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord","-c","/supervisord.conf"]
