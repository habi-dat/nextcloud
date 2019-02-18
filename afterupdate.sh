#!/bin/bash
set +x

envsubst < /fixes/.htaccess > /var/www/html/.htaccess
cp /fixes/LoginController.php /var/www/html/core/Controller/LoginController.php