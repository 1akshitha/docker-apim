
upstream ssltm.am.wso2.com {
    server traffic-manager-1:9443;
    server traffic-manager-2:9443 backup;
}

server {
    listen 80;
    server_name tm.am.wso2.com;
    rewrite ^/(.*) https://tm.am.wso2.com/$1 permanent;
}

server {
    listen 443 ssl;
    server_name tm.am.wso2.com;
    proxy_set_header X-Forwarded-Port 443;
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/apim.key;
    access_log /etc/nginx/log/am/https/tm-access.log;
    error_log /etc/nginx/log/am/https/tm-error.log;

    location / {
               proxy_set_header X-Forwarded-Host $host;
               proxy_set_header X-Forwarded-Server $host;
               proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
               proxy_set_header Host $http_host;
               proxy_read_timeout 5m;
               proxy_send_timeout 5m;
               proxy_pass https://ssltm.am.wso2.com;
        }
}
