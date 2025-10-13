FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive

# Reduce layers and avoid unnecessary packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests \
      apache2 \
      libapache2-mod-mono \
      mono-apache-server4 \
    ; \
    echo 'Listen 8080' > /etc/apache2/ports.conf; \
    a2enmod mono || true; \
    printf 'ServerName localhost\n' > /etc/apache2/conf-available/servername.conf; \
    a2enconf servername; \
    a2dismod mpm_event || true; \
    a2enmod mpm_prefork || true; \
    printf '%s\n' \
      '<VirtualHost *:8080>' \
      '  ServerName localhost' \
      '  DocumentRoot /app' \
      '  MonoServerPath webforms "/usr/bin/mod-mono-server4"' \
      '  MonoApplications webforms "/:/app"' \
      '  MonoSetEnv webforms MONO_IOMAP=all' \
      '  <Location "/">' \
      '    SetHandler mono' \
      '    MonoSetServerAlias webforms' \
      '    Require all granted' \
      '  </Location>' \
      '  DirectoryIndex Default.aspx' \
      '</VirtualHost>' \
      > /etc/apache2/sites-available/000-default.conf

WORKDIR /app
COPY ./app/ /app/

EXPOSE 8080

CMD ["apache2ctl", "-D", "FOREGROUND"]
