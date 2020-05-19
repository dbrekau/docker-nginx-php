#!/bin/sh

# Start nginx
/usr/sbin/nginx
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi
echo "nginx running..."

# Allow Environment in PHP-FPM
if [ $NOTCLEARENV -eq 1 ]; then
  echo "clear_env = no" >> /etc/php7/php-fpm.d/www.conf
fi

# Start php7-fpm
/usr/sbin/php-fpm7
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start php-fpm7: $status"
  exit $status
fi
echo "php-fpm7 running..."

while sleep 60; do
  ps | grep nginx | awk '{print $1}' | grep $(cat /run/nginx/nginx.pid)
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "nginx failed: $STATUS"
    exit 1
  fi

  ps | grep php-fpm7 | grep master
  STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo "php-fpm7 failed: $STATUS"
    exit 1
  fi
done
