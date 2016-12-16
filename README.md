快速配置https的脚本

let's encrypt提供技术支持

# 支持
	> Nginx

# 安装步骤

## 1. 现在指定域名的server内添加如下指令

location ^~ /.well-known/acme-challenge {
	alias /usr/share/nginx/html/certificates/dev.magikid.com/.well-known/acme-challenge/;
	try_files $uri =404;
}

## 2. 执行https.sh这个脚本，根据提示输入`域名`, 和`WEB项目的根路径`

## 3. https配置证书的生成路径`/usr/share/nginx/html/certificates/$domain`这个路径下

## 4. 把`/usr/share/nginx/html/certificates/$domain/$domain.conf`文件加入`nginx`的配置

## 把`renew.sh`这个脚本加入`crontab`定时任务
