FROM nextcloud:21.0.2

RUN \
  apt-get update \
  && apt-get -y install gettext-base jq \
  && apt-get clean \
&& rm -rf /var/lib/apt/lists/*

ADD fixes /fixes
 
ADD images /images
ADD icons /icons
ADD habidat-bootstrap.sh /habidat-bootstrap.sh
ADD habidat-fixes.sh /habidat-fixes.sh
ADD habidat-afterupdate.sh /habidat-afterupdate.sh
ADD habidat-add-externalsite.sh /habidat-add-externalsite.sh

RUN chmod +x /habidat-bootstrap.sh && chmod +x /habidat-afterupdate.sh && chmod +x /habidat-add-externalsite.sh
