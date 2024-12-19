#!/bin/bash
sudo apt update -y
sudo apt install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
# Create a simple index.html file
echo "<html><body><h1>Hello from $(hostname -f)</h1></body></html>" > /var/www/html/index.html