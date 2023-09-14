#!/bin/bash

# sudo docker run --name mono-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password -d mysql
git clone https://github.com/amitsatpute-pyjs/kafka-connect.git /home/ubuntu/app/kafka-connect/
cd /home/ubuntu/app/kafka-connect/
docker-compose up -d postgres
git clone https://github.com/amitsatpute-pyjs/monolith-to-microservices.git /home/ubuntu/app/monolith-to-microservices/
cd /home/ubuntu/app/monolith-to-microservices/monolith
cp .env.example .env
export PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
sed -i 's/<username>/root/g' .env
sed -i 's/<password>/password/g' .env
npm ci
sudo npm install pm2 -g
pm2 --name monoApp start npm -- start
# npm start
cd ../react-app
npm ci
pm2 --name monoUI start npm -- start
# npm start

