#!/bin/sh

domain=$1

certificateDir="/usr/share/nginx/html/certificates/$domain"

cd $certificateDir

rm dev.magikid.com.pem;

csrFileName="$domain.csr"

crtFileName="$domain.crt"

acmeChallengeDir="$certificateDir/.well-known/acme-challenge/"

if [ ! -d $acmeChallengeDir ]; then
    mkdir -p $acmeChallengeDir
fi

python acme_tiny.py --account-key ./account.key --csr $csrFileName --acme-dir $acmeChallengeDir > $crtFileName

wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem

pemFileName="$domain.pem"

cat $crtFileName intermediate.pem > $pemFileName

rm -Rf $acmeChallengeDir

echo -e `date` >> record.md
echo -e "\n\n" >> record.md

sudo service nginx reload
