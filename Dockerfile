FROM google/dart

WORKDIR /app

ADD . /build

RUN cd /build/web_client && pub get && pub build && mv build/web /app/ && cd /build/server && pub get && dart --snapshot=/app/server.snapshot bin/server.dart && cd / && rm /build -R && echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && apt-get -q update && apt-get install --no-install-recommends -y -q ffmpeg

VOLUME /app/data

EXPOSE 8080

CMD []
ENTRYPOINT ["/usr/bin/dart", "server.snapshot"]

