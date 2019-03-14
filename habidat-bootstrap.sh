#!/bin/bash
set +x

envsubst < /fixes/.htaccess > /var/www/html/.htaccess
cp /fixes/LoginController.php /var/www/html/core/Controller/LoginController.php

echo "[HABIDAT] Installing Nextcloud..."
php occ maintenance:install --database "mysql" --database-host "$HABIDAT_DOCKER_PREFIX-nextcloud-db" --database-name "nextcloud"  --database-user "nextcloud" --database-pass "$HABIDAT_MYSQL_PASSWORD" --admin-user "$HABIDAT_ADMIN_USER" --admin-pass "$HABIDAT_ADMIN_PASSWORD"

sed -i "/);/i \
'overwriteprotocol' => 'https'," /var/www/html/config/config.php

#install and configure nextcloud
echo "[HABIDAT] Configuring Nextcloud..."
php occ config:system:set trusted_domains 2 --value="$HABIDAT_NEXTCLOUD_SUBDOMAIN.$HABIDAT_DOMAIN"
php occ config:system:set default_language --value=de
php occ config:system:set force_language --value=de
php occ config:system:set lost_password_link --value="$HABIDAT_PROTOCOL://$HABIDAT_USER_SUBDOMAIN.$HABIDAT_DOMAIN/lostpasswd"

#install calendar
echo "[HABIDAT] Installing Calendar..."
php occ app:install calendar
php occ app:enable calendar

#add discourse icon and external site
echo "[HABIDAT] Installing External Sites..."
php occ app:install external
php occ app:enable external

APPDATA_DIR=$(find /var/www/html/data/ -type d -regex "/var/www/html/data/appdata[^/]*" | tr -d "\r" | head -n1)

/habidat-update-externalsites.sh

mkdir -p "$APPDATA_DIR/external/icons/"
cp /icons/* "$APPDATA_DIR/external/icons/"

#theming
echo "[HABIDAT] Theming..."
mkdir -p "$APPDATA_DIR/theming/images"
cp /images/logo "$APPDATA_DIR/theming/images"
cp /images/background "$APPDATA_DIR/theming/images"
php occ config:app:set theming color --value="#A40023"
php occ config:app:set theming name --value="$HABIDAT_TITLE"
php occ config:app:set theming url --value="$HABIDAT_PROTOCOL://$HABIDAT_DOMAIN"
php occ config:app:set theming slogan --value="$HABIDAT_DESCRIPTION"
php occ config:app:set theming backgroudMime --value="image/jpeg"
php occ config:app:set theming logoMime --value="image/png"
php occ maintenance:theme:update

#install and configre antivirus
echo "[HABIDAT] Setting up antivirus..."
php occ app:install files_antivirus
php occ app:enable files_antivirus
php occ config:app:set files_antivirus av_mode --value="daemon"
php occ config:app:set files_antivirus av_host --value="$HABIDAT_DOCKER_PREFIX-nextcloud-antivirus"
php occ config:app:set files_antivirus av_infected_action --value="only_log"
php occ config:app:set files_antivirus av_port --value="3310"


php occ app:install discoursesso
php occ app:enable discoursesso
php occ config:app:set discoursesso clientsecret --value="$HABIDAT_DISCOURSE_SSO_SECRET"
php occ config:app:set discoursesso clienturl --value="$HABIDAT_PROTOCOL://$HABIDAT_DISCOURSE_SUBDOMAIN.$HABIDAT_DOMAIN"


#install tasks
#php occ app:install tasks
#php occ app:enable tasks

#setup ldap
echo "[HABIDAT] Setting up LDAP..."
php occ app:enable user_ldap
php occ ldap:create-empty-config
php occ ldap:set-config s01 ldapHost "$HABIDAT_DOCKER_PREFIX-ldap"
php occ ldap:set-config s01 ldapPort 389
php occ ldap:set-config s01 ldapLoginFilter "(&(objectclass=inetOrgPerson)(|(uid=%uid)(|(cn=%uid)(mail=%uid))))"
php occ ldap:set-config s01 hasMemberOfFilterSupport 1
php occ ldap:set-config s01 lastJpegPhotoLookup 0
php occ ldap:set-config s01 ldapAgentName "cn=admin,$HABIDAT_LDAP_BASE"
php occ ldap:set-config s01 ldapAgentPassword "$HABIDAT_LDAP_ADMIN_PASSWORD"
php occ ldap:set-config s01 ldapBase "$HABIDAT_LDAP_BASE"
php occ ldap:set-config s01 ldapBaseGroups "ou=groups,$HABIDAT_LDAP_BASE"
php occ ldap:set-config s01 ldapBaseUsers "ou=users,$HABIDAT_LDAP_BASE"
php occ ldap:set-config s01 ldapCacheTTL 120
php occ ldap:set-config s01 ldapConfigurationActive 1
php occ ldap:set-config s01 ldapEmailAttribute mail
php occ ldap:set-config s01 ldapExperiencedAdmin 0
php occ ldap:set-config s01 ldapExpertUUIDGroupAttr cn
php occ ldap:set-config s01 ldapExpertUUIDUserAttr uid
php occ ldap:set-config s01 ldapGidNumber gidNumber
php occ ldap:set-config s01 ldapGroupDisplayName cn
php occ ldap:set-config s01 ldapGroupFilter "(&(|(objectclass=groupOfNames)))"
php occ ldap:set-config s01 ldapGroupFilterMode 0
php occ ldap:set-config s01 ldapGroupFilterObjectclass "groupOfNames"
php occ ldap:set-config s01 ldapGroupMemberAssocAttr member
php occ ldap:set-config s01 ldapLoginFilterAttributes cn
php occ ldap:set-config s01 ldapLoginFilterEmail 1
php occ ldap:set-config s01 ldapLoginFilterMode 0
php occ ldap:set-config s01 ldapLoginFilterUsername 1
php occ ldap:set-config s01 ldapNestedGroups 0
php occ ldap:set-config s01 ldapPagingSize 1000
php occ ldap:set-config s01 ldapQuotaDefault 10GB
php occ ldap:set-config s01 ldapTLS 0
php occ ldap:set-config s01 ldapUserDisplayName cn
php occ ldap:set-config s01 ldapUserFilter "(objectclass=inetOrgPerson)"
php occ ldap:set-config s01 ldapUserFilterMode 0
php occ ldap:set-config s01 ldapUserFilterObjectclass inetOrgPerson
php occ ldap:set-config s01 ldapUuidGroupAttribute auto
php occ ldap:set-config s01 ldapUuidUserAttribute auto
php occ ldap:set-config s01 turnOffCertCheck 0
php occ ldap:set-config s01 turnOnPasswordChange 0
php occ ldap:set-config s01 useMemberOfToDetectMembership 0        

# version specific for 15.0.4
php occ maintenance:mode --on
php occ db:convert-filecache-bigint --no-interaction
php occ maintenance:mode --off

