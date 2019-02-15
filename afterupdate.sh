#!/bin/bash
set -e

envsubst < /fixes/.htaccess > /var/www/html/.htaccess
envsubst < /fixes/LoginController.php > /var/www/html/core/Controller/LoginController.php