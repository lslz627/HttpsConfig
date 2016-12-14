	location ^~ /.well-known/acme-challenge {
		alias /usr/share/nginx/html/certificates/dev.magikid.com/.well-known/acme-challenge/;
		try_files $uri =404;
	}

