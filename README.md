# wikitech-static-docker

This builds a docker image that contains a static snapshot of (most
of) wikitech-static, along with a static search index.

Wikitech-static is intended for emergency documentation when the
live wikitech.wikimedia.org is down. It is not meant to be beautiful
or complete.

This build process takes hours, and scrapes the live wikitch site. Please
don't run a denial-of-service attack on wikitech when debugging this site!
A simple rump image can be created by altering

    -#L99999990 \

in the dockerfile to a smaller number of pages. 50 is a good place to start.

== Tech ==

The site is captured using httrack. Each page is downloaded and urls are
mangled into relative links to point back at the static site. Httrack
is a very old tool with weird cli options but is still supported by
upstream Debian packagers.

Search uses lunr packages from npm and a somewhat-custom indexing
script, build_index.js. Building the index itself requires a ton
of RAM but the final index itself isn't too big to download.

== Pages ==

In order to reduce build time, container size, and load on production
wikitech, we exclude many types of pages from this snapshot. The
excluded page types are denoted with a '-' in the httrack command
(see? weird cli options!), for example

    -*Special:* \
    -*Portal:* \
    -*Nova_Resource:* \

etc. If you see a set of pages that you think you'll need in an
emergency, please add them back in!

== Indexed Pages ==

In an attempt to keep the search index a modest size, I've excluded
several page types from the index, e.g. pages marked as obsolete. This
is accomplised via unsophisticated checks in the findHtml() function in
build_index.js

sudo docker run -it --rm -d -p 80:80 --name wts <image id>
