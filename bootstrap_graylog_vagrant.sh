#basierend auf https://www.bro.org/sphinx/install/install.html
#bei Fehler abbrechen
set -e
# Verwende google-nameserver, andere machen Probleme
echo "starting bootstrap.."
source /home/vagrant/config
sudo sed -ir 's/[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/8.8.8.8/g' /etc/resolv.conf
sudo apt update
#default-jre funktioniert nicht (vers. 11.0.1)
sudo apt install -y apt-transport-https openjdk-8-jre-headless uuid-runtime pwgen

#mongodb-org funktioniert nicht
sudo apt install -y mongodb

sudo apt-get install -y apt-transport-https
wget https://packages.graylog2.org/repo/packages/graylog-2.4-repository_latest.deb
sudo dpkg -i graylog-2.4-repository_latest.deb
sudo apt-get update
sudo apt-get -y install graylog-server
##hire wird elasticsearch 6.5.4 einstalliert, nicht kompatibel mit graylog 2.5/2.4
#wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.4.deb
#sudo dpkg -i elasticsearch-6.5.4.deb


#hier wird elasticsearch 5.6.14 installiert, scheint auch nicht zu funktionieren(?)
#curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.14.deb
#sudo dpkg -i elasticsearch-5.6.14.deb
#sudo /etc/init.d/elasticsearch start

#sudo apt-get -y install elasticsearch


#hier wird elasticsearch 2.x installiert, funktioniert mit graylog 2.x 
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
sudo apt-get update && sudo apt-get install elasticsearch
  
sudo mv server.conf /etc/graylog/server/server.conf

###### ersetze Werte aus der server.conf von graylog mit eigenen Werten aus der config-Datei
sudo sed -i "s@REST_LISTEN_URI@http://$MY_IP@g" /etc/graylog/server/server.conf

#Das ist nicht nötig, nur bei HTTP-Proxy, dann darf es nicht 0.0.0.0 sein
#sudo sed -i "s@REST_TRANSPORT_URI@http://$MY_IP@g" /etc/graylog/server/server.conf

sudo sed -i "s@WEB_LISTEN_URI@http://$MY_IP@g" /etc/graylog/server/server.conf

#generiere salt für die gespeicherten PWs
secret=$(pwgen -N 1 -s 96)
#füge salt in die server.conf von graylog ein
sudo sed -i "s@password_secret = @password_secret = $secret@g" /etc/graylog/server/server.conf
#füge username aus config in die server.conf ein
sudo sed -i "s@#root_username = admin@root_username = $GRAYLOG_ADMIN@g" /etc/graylog/server/server.conf

#erstelle PW anhand der config-Datei, hash es, schneide ab Whitespace
password=$(echo -n $GRAYLOG_PASSWORD | shasum -a 256 | cut -d " " -f1)
#füge erstelltes PW in die server.conf von graylog
sudo sed -i "s@root_password_sha2 =@root_password_sha2 =$password@g" /etc/graylog/server/server.conf

sudo wget -p /etc/graylog/server/ https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
sudo tar xf /etc/graylog/server/GeoLite2-City.tar.gz
sudo cp /etc/graylog/server/GeoLite2*/GeoLite2-City.mmdb .

#passwort für graylog erstellen und in server.conf einfügen
echo aa35a44f-c221-460d-ac09-5013ad61339a >> node-id && sudo mv node-id /etc/graylog/server/node-id
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo service elasticsearch start
sudo service mongodb start
sudo mongorestore -d graylog /home/vagrant/graylog
sudo systemctl enable graylog-server
sudo systemctl start graylog-server


#TODO: IPs etc in server.conf on-demand editieren

