#!/bin/bash

domains=(cream-fm.art api.cream-fm.art)
rsa_key_size=4096
data_path="./certbot"
email="" # Add your email (optional)
staging=1 # Set to 0 for production

# Create required directories
mkdir -p "$data_path/conf/live/$domains"
mkdir -p "$data_path/www"

# Create dummy certificates for Nginx startup
openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1 \
  -keyout "$data_path/conf/live/$domains[0]/privkey.pem" \
  -out "$data_path/conf/live/$domains[0]/fullchain.pem" \
  -subj "/CN=localhost"

# Start nginx
docker-compose up -d nginx

# Request Let's Encrypt certificates (staging)
for domain in "${domains[@]}"; do
  docker-compose run --rm certbot certonly \
    --webroot -w /var/www/certbot \
    --email $email \
    --agree-tos --no-eff-email \
    -d $domain \
    --staging
done

# Request Let's Encrypt certificates (production)
# Remove --staging flag for production certificates
# Remember Let's Encrypt rate limits!

# Restart nginx
docker-compose exec nginx nginx -s reload