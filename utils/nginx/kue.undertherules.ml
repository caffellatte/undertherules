# the IP(s) on which your node server is running. I chose port 8294.
upstream app_kue_undertherules {
    server 127.0.0.1:8816;
    keepalive 8;
}

# the nginx server instance
server {
    listen 0.0.0.0:80;
    server_name kue.undertherules.ml;
    access_log /var/log/nginx/kue.undertherules.ml.log;

    # pass the request to the node.js server with the correct headers
    # and much more can be added, see nginx config options
    location / {
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
      proxy_set_header X-NginX-Proxy true;

      proxy_pass http://app_kue_undertherules/;
      proxy_redirect off;

      auth_basic "Restricted";
      auth_basic_user_file /etc/nginx/.htpasswd;
    }
 }
