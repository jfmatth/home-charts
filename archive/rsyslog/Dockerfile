FROM ubuntu
RUN apt update && apt install rsyslog -y
# RUN echo '$ModLoad imudp \n\
# $UDPServerRun 514 \n\
# $ModLoad imtcp \n\
# $InputTCPServerRun 514 \n\
# $template RemoteStore, "/var/log/remote/%$year%/%$Month%/%$Day%/%$Hour%.log" \n\
# :source, !isequal, "localhost" -?RemoteStore \n\
# :source, isequal, "last" ~ ' > /etc/rsyslog.conf
ENTRYPOINT ["rsyslogd", "-n"]