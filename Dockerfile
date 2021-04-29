
FROM nginx
RUN apt update && apt upgrade -y
COPY index.html /usr/share/nginx/html
