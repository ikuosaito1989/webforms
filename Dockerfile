FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive

# Reduce layers and avoid unnecessary packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends --no-install-suggests \
      apache2 \
      libapache2-mod-mono \
      mono-apache-server4 \
      ca-certificates \
      wget \
      unzip \
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
RUN set -eux; \
    mkdir -p /app/App_Data; \
    chown -R www-data:www-data /app/App_Data

# Fetch required .NET assemblies (Dapper and MySQL Connector) without NuGet client
RUN set -eux; \
    mkdir -p /tmp/nuget /app/bin; \
    # Download .nupkg files directly
    wget -O /tmp/nuget/dapper.1.42.0.nupkg https://api.nuget.org/v3-flatcontainer/dapper/1.42.0/dapper.1.42.0.nupkg; \
    wget -O /tmp/nuget/mysql.data.8.0.33.nupkg https://api.nuget.org/v3-flatcontainer/mysql.data/8.0.33/mysql.data.8.0.33.nupkg; \
    # Extract and copy the assemblies into /app/bin
    unzip -q /tmp/nuget/dapper.1.42.0.nupkg -d /tmp/nuget/dapper; \
    unzip -q /tmp/nuget/mysql.data.8.0.33.nupkg -d /tmp/nuget/mysql.data; \
    FOUND_DAPPER=; for tfm in net45 net451 net40; do \
      if [ -f "/tmp/nuget/dapper/lib/$tfm/Dapper.dll" ]; then cp "/tmp/nuget/dapper/lib/$tfm/Dapper.dll" /app/bin/; FOUND_DAPPER=1; break; fi; \
    done; \
    if [ -z "$FOUND_DAPPER" ]; then echo 'Preferred Dapper.dll not found, dumping layout:' >&2; ls -R /tmp/nuget/dapper >&2; exit 1; fi; \
    FOUND_MYSQL=; for tfm in net462 net48 net452 net45 net40; do \
      if [ -f "/tmp/nuget/mysql.data/lib/$tfm/MySql.Data.dll" ]; then cp "/tmp/nuget/mysql.data/lib/$tfm/MySql.Data.dll" /app/bin/; FOUND_MYSQL=1; break; fi; \
    done; \
    if [ -z "$FOUND_MYSQL" ]; then echo 'Preferred MySql.Data.dll not found, dumping layout:' >&2; ls -R /tmp/nuget/mysql.data >&2; exit 1; fi

EXPOSE 8080

CMD ["apache2ctl", "-D", "FOREGROUND"]
