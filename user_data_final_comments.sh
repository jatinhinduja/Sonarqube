#!/bin/bash
yum update -y
#to be deleted (apache) 
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo “Hello World from $(hostname -f)” > /var/www/html/index.html
#installing git 
sudo yum install git -y    
sudo git clone https://github.com/jatinhinduja/Sonarqube.git #cloning github repo for setting up sonar properties
#installing postgresql
sudo amazon-linux-extras install postgresql10
sudo yum install -y postgresql-server postgresql-devel
sudo /usr/bin/postgresql-setup --initdb
sudo systemctl start postgresql
#creating user,database and granting priviliges to user for db
sudo -u postgres psql -c "create user sonar with encrypted password 'H3LLoJ4t1n';"
sudo -u postgres psql -c 'create database sonarqube;'
sudo -u postgres psql -c 'grant all privileges on database sonarqube to sonar;'
sudo cp -f Sonarqube/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf #updating properties file from Sonarqube repo to psql
sudo systemctl restart postgresql
#create a non-root Sonar System User
sudo groupadd sonar # creating user group
sudo useradd -c “SonarDemoJstw” -d /opt/sonarqube -g sonar -s /bin/bash sonar # creating user named sonar without sign in options
sudo passwd sonar # set a password to activate our user
sudo usermod -a -G sonar ec2-user # add the user to the sudo groups
#we will use version 7.9+ of Sonar that need Java 11
sudo curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz # downloading jdk11 zip file
# unzip and move files to the correct place
sudo tar zxvf openjdk-11.0.1_linux-x64_bin.tar.gz
sudo mv jdk-11.0.1 /usr/local/
sudo chmod -R 755 /usr/local/jdk-11.0.1 # change access from the jdk folder
sudo cp -f Sonarqube/profile /etc/profile # updating properties file from Sonarqube repo
# sudo source /etc/profile
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.9.1.zip # download Sonarqube
sudo unzip sonarqube-7.9.1.zip # unzip files
sudo mv -v sonarqube-7.9.1/* /opt/sonarqube # move sources to the approriate folder
sudo chown -R sonar:sonar /opt/sonarqube # change ownership of all the sonarqube files to user sonar
sudo chmod -R 775 /opt/sonarqube # change file access privileges
# updating properties file from Sonarqube repo
sudo cp -f Sonarqube/wrapper.conf opt/sonarqube/conf/wrapper.conf
sudo cp -f Sonarqube/sonar.sh /opt/sonarqube/bin/linux-x86-64/sonar.sh
sudo cp -f Sonarqube/sonar.properties /opt/sonarqube/conf/sonar.properties
sudo cp -f Sonarqube/user.conf /etc/systemd/user.conf
sudo cp -f Sonarqube/system.conf /etc/systemd/system.conf
sudo cp -f Sonarqube/limits.conf /etc/security/limits.conf
sudo cp -f Sonarqube/sysctl.conf /etc/sysctl.conf
#Reloading the system configuration and restarting psql
sudo sysctl -p
sudo systemctl restart postgresql
sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh start #starting sonarqube
