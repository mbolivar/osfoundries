#!/bin/bash
token=""

alias jobserv-curl='curl -H '\''OSF-TOKEN: $token'\'' '
filename=blog-post-update-

curl-it(){
    echo "getting notes for $1, $2, $3 ..."
    echo $1 >> ../src/content/blog/$filename$3.md
    jobserv-curl https://api.foundries.io/releases/$2/$3/ | ./mp2md.py >> ../src/content/blog/$filename$3.md
}

highlight-it(){
    echo "getting summaries $1 $2 ..."
    echo "# Summary" >> ../src/content/blog/$filename$2.md
    echo "" >> ../src/content/blog/$filename$2.md
    echo "## Zephyr microPlatform changes for $2" >> ../src/content/blog/$filename$2.md
    echo "" >> ../src/content/blog/$filename$2.md
    jobserv-curl https://api.foundries.io/releases/zmp/$2/ | ./mp2md-highlights.py >> ../src/content/blog/$filename$2.md
    echo "" >> ../src/content/blog/$filename$2.md
    echo "## Linux microPlatform changes for $2" >> ../src/content/blog/$filename$2.md
    echo "" >> ../src/content/blog/$filename$2.md
    jobserv-curl https://api.foundries.io/releases/lmp/$2/ | ./mp2md-highlights.py >> ../src/content/blog/$filename$2.md
    echo "<!--more-->" >> ../src/content/blog/$filename$2.md
}


header(){
cat > ../src/content/blog/$filename$1.md <<EOL
+++
title = "microPlatform update $1"
date = "$2"
tags = ["linux", "zephyr", "update", "cve", "bugs"]
categories = ["updates", "microPlatform"]
banner = "img/banners/update.png"
+++

EOL
}

var=17.10.1
header $var '2017-10-13'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.1
header $var '2017-11-08'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.2
header $var '2017-11-16'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.3
header $var '2017-12-07'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.4
header $var '2017-12-13'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.5
header $var '2018-01-04'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.6
header $var '2018-01-10'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.7
header $var '2018-01-25'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.8
header $var '2018-02-02'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.9
header $var '2018-02-21'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.10
header $var '2018-03-13'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.11
header $var '2018-03-20'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.12
header $var '2018-03-27'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.13
header $var '2018-04-11'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.14
header $var '2018-04-18'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.15
header $var '2018-04-26'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.16
header $var '2018-05-04'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.17
header $var '2018-05-10'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.18
header $var '2018-05-18'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.19
header $var '2018-05-25'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.20
header $var '2018-06-08'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.21
header $var '2018-06-18'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.22
header $var '2018-06-21'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var

var=0.23
header $var '2018-06-29'
highlight-it '# Highlights' $var
curl-it '# Zephyr microPlatform' zmp $var
curl-it '# Linux microPlatform' lmp $var
