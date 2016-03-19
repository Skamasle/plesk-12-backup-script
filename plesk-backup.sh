#!/bin/bash
backuplocation="/backup"

function htdocs(){
mkdir -p $backuplocation/"$(date +'%Y-%m-%d')"/httpdocs
for htdocs in $(mysql -uadmin -p`cat /etc/psa/.psa.shadow` -Dpsa --skip-column-names -e"SELECT name FROM domains" -s)
do 
/bin/tar czvf $backuplocation/"$(date +'%Y-%m-%d')"/httpdocs/$htdocs.tar.gz $(mysql -uadmin -p`cat /etc/psa/.psa.shadow` -Dpsa -e"SELECT dom.id, dom.name, www_root FROM domains dom LEFT JOIN hosting d ON (dom.id = d.dom_id) WHERE dom.name = '$htdocs'" -s --skip-column-names | awk '{print $3}')
done
}

function dbs(){
mkdir -p $backuplocation/"$(date +'%Y-%m-%d')"/databases
for db in $(mysql -uadmin -p`cat /etc/psa/.psa.shadow` -Dpsa --skip-column-names -e"SELECT name FROM data_bases" -s) 
do 
/usr/bin/mysqldump -uadmin -p`cat /etc/psa/.psa.shadow` $db | gzip > $backuplocation/"$(date +'%Y-%m-%d')"/databases/$db.sql.gz
done
}

function mails(){
mkdir -p $backuplocation/"$(date +'%Y-%m-%d')"/emails
find /var/qmail/mailnames -type d -maxdepth 1 -mindepth 1 -exec tar czvf {}.tar.gz {}  \;
mv /var/qmail/mailnames/*.tar.gz $backuplocation/"$(date +'%Y-%m-%d')"/emails/
}

htdocs
dbs
mails


