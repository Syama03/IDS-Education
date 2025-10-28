FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y snort

COPY snort.conf /etc/snort/snort.conf
COPY local.rules /etc/snort/rules/local.rules

CMD ["snort", "-A", "console", "-i", "isolated_net", "-c", "/etc/snort/snort.conf", "-k", "none"]
