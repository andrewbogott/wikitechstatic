FROM debian:bookworm AS httrack
  
RUN apt-get update
RUN apt-get install -y httrack=3.49.4-1 


WORKDIR /app
RUN httrack --update \
    --update \
    -F "httrack building wikitech-static" \
    --keep-alive \
    --search-index \
    -#L99999990 \
    --connection-per-second=5000 \
    --sockets=99 \
    --max-rate=1000000000 \
    --disable-security-limits \
    -v \
    -wikitech.wikimedia.org/wiki/Special:* \
    -wikitech.wikimedia.org/wiki/Nova_Resource:* \
    -wikitech.wikimedia.org/w/index.php?title=Special \
    -*Special:* \
    -*Nova_Resource:* \
    -*oldid=* \
    -*action=* \
    -*index.php=* \
    https://wikitech.wikimedia.org


FROM node:latest AS node
WORKDIR /app
RUN npm install lunr
RUN npm install cheerio
COPY build_index.js /app
COPY --from=httrack /app/wikitech.wikimedia.org /app/wikitech.wikimedia.org
RUN node --max_old_space_size=4000 /app/build_index.js


FROM nginx:latest
EXPOSE 80
WORKDIR /app
COPY --from=httrack /app/wikitech.wikimedia.org /usr/share/nginx/html
COPY --from=node /app/node_modules/lunr /usr/share/nginx/html/libs/lunr
COPY --from=node /app/lunr_index.js /usr/share/nginx/html/libs/lunr/lunr_index.js
COPY search_prefix.html /app

# A bit of site branding:
COPY wikitechstaticicon.svg /usr/share/nginx/html/static/images/icons/wikitech.svg
COPY wikitech-static-wordmark.svg /usr/share/nginx/html/static/images/mobile/copyright/wikitech-wordmark.svg

# Insert search bar on every page (expensive!)
# RUN find /usr/share/nginx/html/wiki -name "*.html" -exec sed -i 1r/app/search_prefix.html {} \;

# Insert search bar only on main page
RUN sed -i 1r/app/search_prefix.html /usr/share/nginx/html/wiki/Main_Page.html
