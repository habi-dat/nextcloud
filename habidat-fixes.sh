#!/bin/bash
set +x

envsubst < /fixes/.htaccess > /var/www/html/.htaccess
cp /fixes/LoginController.php /var/www/html/core/Controller/LoginController.php

if [ $HABIDAT_SSO == "true" ]
then
	cp /fixes/SAMLController.php /var/www/html/custom_apps/user_saml/lib/Controller/SAMLController.php
fi	
