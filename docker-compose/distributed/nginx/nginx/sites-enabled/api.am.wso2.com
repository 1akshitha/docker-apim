
upstream sslapi.am.wso2.com {
    server am.components:49500;
    server am.components:49600 backup;
}

server {
    listen 80;
    server_name api.am.wso2.com;
    rewrite ^/(.*) https://api.am.wso2.com/$1 permanent;
}

server {
    listen 443 ssl;
    server_name api.am.wso2.com;
    proxy_set_header X-Forwarded-Port 443;
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/apim.key;
    access_log /etc/nginx/log/am/https/access.log;
    error_log /etc/nginx/log/am/https/error.log;
    location / {
               proxy_set_header X-Forwarded-Host $host;
               proxy_set_header X-Forwarded-Server $host;
               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
               proxy_set_header Host $http_host;
               proxy_read_timeout 5m;
               proxy_send_timeout 5m;
               proxy_pass https://sslapi.am.wso2.com;
        }  
}
