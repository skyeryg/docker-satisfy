FROM alpine:3.8

ARG APP_USER=satisfy

ENV \
    COMPOSER_VERSION=1.7.3 \
    SATISFY_VERSION=3.0.4 \
    LD_PRELOAD=/usr/lib/preloadable_libiconv.so \
    PHP_INI_PATH=/etc/php7/php.ini \
    PHP_INI_SCAN_DIR=/etc/php7/conf.d \
    APP_ROOT=/app \
    APP_USER=${APP_USER}

LABEL \
      maintainer="Anastas Dancha <https://github.com/anapsix>" \
      com.php.composer.version="${COMPOSER_VERSION}" \
      playbloom.satisfy.version="${SATISFY_VERSION}"

RUN \
    apk upgrade --no-cache && \
    apk add --no-cache php7-apcu php7-bcmath php7-ctype php7-curl php7-dom php7-fileinfo \
    php7-iconv php7-json php7-mbstring php7-openssl php7-phar php7-session \
    php7-simplexml php7-xml php7-tokenizer \
    libxml2-dev inotify-tools jq zip curl openssh-client git && \
    apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv && \
    curl -o /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    chmod +x /usr/local/bin/composer && \
    rm -rf /var/cache/apk/* && \
    if [[ "$APP_USER" != "root" ]]; then adduser -h ${APP_ROOT} -D -H ${APP_USER}; fi

WORKDIR ${APP_ROOT}

RUN \
    yes | composer create-project --no-dev playbloom/satisfy . ${SATISFY_VERSION} && \
    rm ${APP_ROOT}/app/config/parameters.yml && \
    chown -R ${APP_USER}:${APP_USER} ${APP_ROOT}

COPY *.sh /
EXPOSE 8080

USER ${APP_USER}
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "satisfy" ]