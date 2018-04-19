#!/bin/sh

set -e

/usr/sbin/nginx

Scout2 --no-browser --report-dir /usr/share/nginx/html

mv /usr/share/nginx/html/report.html /usr/share/nginx/html/index.html

printf "\n\n*** Visit ***\n\nhttp://localhost:22222\n\n*** to view the report ***\n\n"

tail -f /var/log/nginx/access.log
