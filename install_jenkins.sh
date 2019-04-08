#! /bin/bash
echo "Install Java 8"
   yum remove java* -y
   yum install java-1.8.0-openjdk -y

   echo "Install Jenkins stable release"
   wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
   rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
   yum install jenkins -y
   /etc/init.d/jenkins start


