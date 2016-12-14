#!/bin/sh

# 制作csr文件的网站
# https://www.digicert.com/easy-csr/openssl.htm?rid=115630

# 制作let's encrypt的网站
# https://imququ.com/post/letsencrypt-certificate.html

echo 'Please Input A Domain'

read domain

valid=`echo $domain | egrep -o -e '(\w*\.){1,}\w*'`

if [ -z "$valid" ]; then
  echo 'invalid domain'
  exit
fi

echo 'Please Input WebRoot Path'

read webRoot

if [ ! -d $webRoot ]; then
  echo 'invalid webRoot'
  exit
fi

# echo 'Please Input Certificate Path'

# read certificateDir

# if [ ! -d $certificateDir -o ! -w $certificateDir ]; then
  # echo 'invalid path or not write'
  # exit
# fi

# certificateDir=`echo $certificateDir | sed 's/\/$//'`

# certificateDir="$certificateDir/$domain"

certificateDir="/usr/share/nginx/html/certificates/$domain"

if [ ! -d $certificateDir ]; then
  mkdir -p $certificateDir
  # create .well-known/acme-challenge
fi

rm -Rf "$certificateDir/*"
acmeChallengeDir="$certificateDir/.well-known/acme-challenge/"
mkdir -p $acmeChallengeDir

cd $certificateDir

# 导出账号
openssl genrsa 4096 > account.key

domainKeyFileName="$domain.key"
# 导出域名
openssl genrsa 4096 > $domainKeyFileName

csrFileName="$domain.csr"

# 创建CSR文件
openssl req -new -newkey rsa:4096 -nodes -out $csrFileName -keyout $domainKeyFileName -subj "/C=CN/ST=ShangHai/L=ShangHai/O=Magikid Inc./CN=$domain"

wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py

crtFileName="$domain.crt"

python acme_tiny.py --account-key ./account.key --csr $csrFileName --acme-dir $acmeChallengeDir > $crtFileName

wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem

pemFileName="$domain.pem"

cat $crtFileName intermediate.pem > $pemFileName

domainServerConfigFileName="$domain.conf"

conf="server { \n
        listen       443; \n
        server_name  $domain; \n
        root         $webRoot; \n
 \n
		    ssl                  on; \n
        ssl_certificate      $certificateDir/$domain.pem; \n
        ssl_certificate_key  $certificateDir/$domain.key; \n
 \n
       	ssl_session_timeout  5m; \n
 \n
       	ssl_protocols  SSLv2 SSLv3 TLSv1; \n
      	ssl_ciphers  HIGH:!aNULL:!MD5; \n
      	ssl_prefer_server_ciphers   on; \n
 \n
        access_log  /var/log/nginx/host.access.log  main; \n
		    index index.php index.html index.htm; \n
 \n
        location ~ /\.git { \n
          deny all; \n
        } \n
 \n
        location ~ /README { \n
          deny all; \n
        } \n
 \n
        location / { \n
          try_files \$uri \$uri/ /index.php; \n
        } \n
 \n
        error_page 404 /404.html; \n
        location = /40x.html { \n
        } \n
 \n
        error_page 500 502 503 504 /50x.html; \n
        location = /50x.html { \n
        } \n
 \n
        location ~ \.php$ { \n
            fastcgi_pass   127.0.0.1:9000; \n
            fastcgi_index  index.php; \n
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name; \n
            include        fastcgi_params; \n
        } \n
}"

echo -e $conf > $domainServerConfigFileName

rm -Rf $acmeChallengeDir
