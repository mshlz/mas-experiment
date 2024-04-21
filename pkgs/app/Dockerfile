FROM ubuntu:23.10 as base

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Etc/UTC

WORKDIR /var/app
EXPOSE 3001

RUN apt update && apt install -y vim curl socat wget htop mtr git openssh-server net-tools dnsutils sudo lsof
# ENV BASH_ENV ~/.bashrc
ENV VOLTA_HOME /root/.volta
ENV PATH $VOLTA_HOME/bin:$PATH

ENV NODE_VERSION 20.12.2
RUN curl https://get.volta.sh | bash
RUN $VOLTA_HOME/bin/volta install node@$NODE_VERSION
RUN $VOLTA_HOME/bin/volta install yarn@4.1.1
RUN node -v && yarn -v

# fix pid1
ENV PATH $VOLTA_HOME/tools/image/node/$NODE_VERSION/bin/:$PATH

FROM base

COPY . .

ENTRYPOINT [ "node", "src/app.js" ]
