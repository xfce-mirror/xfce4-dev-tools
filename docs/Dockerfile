FROM xfce/xfce-build:latest

MAINTAINER Xfce Development Team

ENV DEBIAN_FRONTEND noninteractive

# Install nginx
RUN apt-get update \
  && apt-get -y --no-install-recommends install nginx \
  && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /docs/index.html
COPY style.css /docs/style.css

EXPOSE 8080
VOLUME ["/docs"]

CMD ["nginx"]
