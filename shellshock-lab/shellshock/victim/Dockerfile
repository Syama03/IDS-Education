FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y build-essential wget python3

WORKDIR /usr/src
RUN wget http://ftp.gnu.org/gnu/bash/bash-4.3.tar.gz && \
tar -zxvf bash-4.3.tar.gz && \
cd bash-4.3 && \
./configure && \
make && \
cp bash /usr/local/bin/bash_vulnerable

WORKDIR /app
RUN mkdir cgi-bin

COPY cgi-bin/vulnerable.sh cgi-bin/
RUN chmod +x cgi-bin/vulnerable.sh

EXPOSE 8000

CMD ["python3", "-u", "-m", "http.server", "--cgi", "8000"]
