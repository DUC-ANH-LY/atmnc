FROM php:7.4-apache-bullseye

# Minimal extensions for Roundcube 1.3.9 (complete tarball). Intl/GD omitted to keep image build fast.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libc-client-dev libkrb5-dev libzip-dev libxml2-dev libsqlite3-dev libonig-dev \
    curl \
  && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install -j"$(nproc)" imap pdo pdo_sqlite mbstring zip xml opcache \
  && apt-get purge -y --auto-remove libc-client-dev libkrb5-dev \
  && rm -rf /var/lib/apt/lists/*

RUN sed -ri -e 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

WORKDIR /var/www/html
RUN curl -fsSL "https://github.com/roundcube/roundcubemail/releases/download/1.3.9/roundcubemail-1.3.9-complete.tar.gz" \
  | tar xz --strip-components=1

COPY config.inc.php /var/www/html/config/config.inc.php

# Load schema with sqlite3 CLI. (PHP initdb loads rcmail first and can apply DDL twice.)
RUN apt-get update && apt-get install -y --no-install-recommends sqlite3 \
  && mkdir -p /var/roundcube/db \
  && sqlite3 /var/roundcube/db/roundcube.sqlite < /var/www/html/SQL/sqlite.initial.sql \
  && apt-get purge -y --auto-remove sqlite3 \
  && rm -rf /var/lib/apt/lists/* \
  && chown -R www-data:www-data /var/roundcube/db /var/www/html/temp /var/www/html/logs

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
