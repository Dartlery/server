FROM google/dart

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list && apt-get -q update && apt-get install --no-install-recommends -y -q ffmpeg

WORKDIR /app
VOLUME /app/data

ADD . /build

RUN cd /build/web_client && pub get && pub build && mv build/web /app/ && cd /build/server && pub get && dart --snapshot=/app/server.snapshot bin/server.dart && cd / && rm /build -R

EXPOSE 8080
ENV DARTLERY_MONGO mongodb://127.0.0.1/dartlery
ENV DARTLERY_LOG INFO

CMD []
ENTRYPOINT ["/usr/bin/dart", "server.snapshot"]