#!/bin/bash

# Wait until any other yum process finishes
while fuser /var/lib/rpm/.rpm.lock; do
  echo "Waiting for other yum process to complete..."
  sleep 5
done

# Update yum and install apache
sudo yum clean all
sudo yum update -y
sudo yum install -y httpd

# Enable and start apache
sudo systemctl enable httpd
sudo systemctl start httpd

# Check if Apache is running
if ! systemctl status httpd | grep "running"; then
  echo "Apache installation failed"
  exit 1
fi

# Ensure the web directory exists and create index.html
sudo mkdir -p /var/www/html
echo "<html><body><h1>Hello from $(hostname -f)</h1></body></html>" > /var/www/html/index.html

# Restart Apache to load the index.html page
sudo systemctl restart httpd

echo "Apache Web Server setup complete"
