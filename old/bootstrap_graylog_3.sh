#basierend auf https://www.bro.org/sphinx/install/install.html

# Verwende google-nameserver, andere machen Probleme
sudo sed -ir 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/8.8.8.8/g' /etc/resolv.conf
sudo apt update
#default-jre funktioniert nicht (vers. 11.0.1)
sudo apt-get install -y apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen
wget https://packages.graylog2.org/repo/packages/graylog-3.0-repository_latest.deb
sudo dpkg -i graylog-3.0-repository_latest.deb
sudo apt-get update
sudo apt-get install graylog-server

#mongodb-org funktioniert nicht
sudo apt-get install -y mongodb

sudo apt-get -y install elasticsearch

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install elasticsearch
  #mongorestore
  
sudo mv server.conf /etc/graylog/server/server.conf  
### Hier funktioniert mongorestore nicht? erst mongodb starten?

sudo mongorestore -d graylog ~/graylog
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo service elasticsearch start
sudo service mongodb start
sudo service mongodb enable
echo aa35a44f-c221-460d-ac09-5013ad61339a >> node-id && sudo mv node-id /etc/graylog/server/node-id
sudo systemctl enable graylog-server
sudo systemctl start graylog-server


#TODO: IPs etc in server.conf on-demand editieren

