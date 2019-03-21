#!/bin/bash
set +x

APPDATA_DIR=$(find /var/www/html/data/ -type d -regex "/var/www/html/data/appdata[^/]*" | tr -d "\r" | head -n1)

EXTERNAL_SITES_TEMPLATE='"%s":{"icon":"%s","lang":"","type":"link","device":"","id":"%s","name":"%s","url":"%s"}'
EXTERNAL_SITES='{'
COUNT=0

if [ ! -z "$HABIDAT_DISCOURSE_SUBDOMAIN" ]
then
	if [ "$COUNT" -ne 0 ]
	then
		EXTERNAL_SITES+=","
	fi

	((COUNT+=1))
	EXTERNAL_SITES+=$(printf "$EXTERNAL_SITES_TEMPLATE" "$COUNT" "discourse.ico" "$COUNT" "Discourse" "$HABIDAT_PROTOCOL://$HABIDAT_DISCOURSE_SUBDOMAIN.$HABIDAT_DOMAIN")
fi

if [ ! -z "$HABIDAT_MEDIAWIKI_SUBDOMAIN" ]
then
	if [ "$COUNT" -ne 0 ]
	then
		EXTERNAL_SITES+=","
	fi

	((COUNT+=1))
	EXTERNAL_SITES+=$(printf "$EXTERNAL_SITES_TEMPLATE" "$COUNT" "wiki.png" "$COUNT" "Wiki" "$HABIDAT_PROTOCOL://$HABIDAT_MEDIAWIKI_SUBDOMAIN.$HABIDAT_DOMAIN")
fi

if [ ! -z "$HABIDAT_USER_SUBDOMAIN" ]
then
	if [ "$COUNT" -ne 0 ]
	then
		EXTERNAL_SITES+=","
	fi

	((COUNT+=1))
	EXTERNAL_SITES+=$(printf "$EXTERNAL_SITES_TEMPLATE" "$COUNT" "user.png" "$COUNT" "User*innen" "$HABIDAT_PROTOCOL://$HABIDAT_USER_SUBDOMAIN.$HABIDAT_DOMAIN")
fi

if [ ! -z "$HABIDAT_DIREKTKREDIT_SUBDOMAIN" ]
then
	if [ "$COUNT" -ne 0 ]
	then
		EXTERNAL_SITES+=","
	fi

	((COUNT+=1))
	EXTERNAL_SITES+=$(printf "$EXTERNAL_SITES_TEMPLATE" "$COUNT" "direktkredite.png" "$COUNT" "Direktkredite" "$HABIDAT_PROTOCOL://$HABIDAT_DIREKTKREDIT_SUBDOMAIN.$HABIDAT_DOMAIN")
fi

EXTERNAL_SITES+='}'
php occ config:app:set external sites --value "$EXTERNAL_SITES"