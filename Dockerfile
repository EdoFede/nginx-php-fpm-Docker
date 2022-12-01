ARG BASEIMAGE_BRANCH
FROM edofede/baseimage:$BASEIMAGE_BRANCH

# Install required software
RUN	apk update && \
	apk --no-cache add \
		openssl \
		nginx \
		nginx-mod-http-dav-ext \
		php81 \
		php81-calendar \
		php81-common \
		php81-curl \
		php81-fpm \
		php81-json \
		php81-opcache \
		php81-posix \
		php81-xml && \
	rm -rf /var/cache/apk/*

COPY imageFiles/ /

# Configure PHP-FPM service
RUN	mkdir -p /run/php && \
	chgrp -R www-data /run/php && \
	sed -i \
		-e "s/;daemonize = yes/daemonize = no/" \
		-e "s/;log_level = notice/log_level = warning/" \
		-e "s/;error_log = log\\/php81\\/error.log/error_log = syslog/" \
		/etc/php81/php-fpm.conf && \
	sed -i \
		-e "s/listen = 127.0.0.1:9000/listen = \\/run\\/php\\/php8.1-fpm.sock/" \
		-e "s/;listen.owner = nobody/listen.owner = nobody/" \
		-e "s/;listen.group = nobody/listen.group = www-data/" \
		-e "s/user = nobody/user = nginx/" \
		-e "s/group = nobody/group = www-data/" \
		-e "s/;clear_env = no/clear_env = no/" \
		/etc/php81/php-fpm.d/www.conf && \
	chmod 755 /etc/sv/php-fpm/run && \
	ln -sf /etc/sv/php-fpm /etc/service/ && \
# Configure nginx service
	sed -i '/^worker_processes auto;/a include /etc/nginx/modules/*.conf;' /etc/nginx/nginx.conf && \
	mkdir -p /var/www && \
	chown -R nginx:www-data /var/www && \
	rm -rf /var/www/localhost && \
	mkdir -p /etc/nginx/sites-available && \
	mkdir -p /etc/nginx/sites-enabled && \
	rm -f /etc/nginx/conf.d/default.conf && \
	ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/ && \
	chmod 755 /etc/sv/nginx/run && \
	ln -sf /etc/sv/nginx /etc/service/

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL 	maintainer="Edoardo Federici <hello@edoardofederici.com>" \
		org.label-schema.schema-version="1.0.0-rc.1" \
		org.label-schema.vendor="Edoardo Federici" \
		org.label-schema.url="https://edoardofederici.com" \
		org.label-schema.name="nginx-php-fpm" \
		org.label-schema.description="Docker multiarch image for nginx and PHP-FPM services" \
		org.label-schema.version=$VERSION \
		org.label-schema.build-date=$BUILD_DATE \
		org.label-schema.vcs-url="https://github.com/EdoFede/nginx-php-fpm-Docker" \
		org.label-schema.vcs-ref=$VCS_REF \
		org.label-schema.docker.cmd="docker create --name nginx-php-fpm --publish-all edofede/nginx-php-fpm:latest"

EXPOSE 80
