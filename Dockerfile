## Base: Debian (stable) + Mono official repo
## Rationale: older mono:<tag>-slim images often have EOL apt sources
## which break `apt-get update` during build. Use Debian + Mono repo
## to reliably install xsp4 and runtime.
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

## Install Mono + xsp4 from Debian official repos (no external Mono repo)
## This avoids fetching external GPG keys and works behind restricted networks.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl \
      mono-complete \
      apache2 libapache2-mod-mono mono-apache-server4 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ./app/ /app/

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -fsS http://localhost:8080/ >/dev/null || exit 1

# Configure Apache to serve ASP.NET via mod_mono on port 8080
RUN set -eux; \
    echo 'Listen 8080' > /etc/apache2/ports.conf; \
    a2enmod mono || true; \
    a2enconf mono || true; \
    printf 'ServerName localhost\n' > /etc/apache2/conf-available/servername.conf; \
    a2enconf servername; \
    a2dismod mpm_event || true; \
    a2enmod mpm_prefork || true; \
    printf '%s\n' \
      '<VirtualHost *:8080>' \
      '  ServerAdmin webmaster@localhost' \
      '  ServerName localhost' \
      '  DocumentRoot /app' \
      '  # Explicit mod_mono app binding' \
      '  MonoServerPath webforms "/usr/bin/mod-mono-server4"' \
      '  MonoApplications webforms "/:/app"' \
      '  MonoSetEnv webforms MONO_IOMAP=all' \
      '  # Handle ASP.NET files via Mono' \
      '  AddType application/x-asp-net .aspx .asmx .ashx .asax .ascx .soap .rem .axd' \
      '  <Location "/">' \
      '    SetHandler mono' \
      '    MonoSetServerAlias webforms' \
      '    Require all granted' \
      '  </Location>' \
      '  DirectoryIndex Default.aspx' \
      '  ErrorLog ${APACHE_LOG_DIR}/error.log' \
      '  CustomLog ${APACHE_LOG_DIR}/access.log combined' \
      '</VirtualHost>' \
      > /etc/apache2/sites-available/000-default.conf

CMD ["apache2ctl", "-D", "FOREGROUND"]
