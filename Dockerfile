FROM ajones17/frr:latest

RUN ["apk", "update"]
RUN ["apk", "upgrade", "--available"]

RUN ["apk", "add", \
      "tcpdump", \
      "curl"]

ADD enable.sh /enable.sh
RUN chmod +x /enable.sh
ENTRYPOINT ["/enable.sh"]
