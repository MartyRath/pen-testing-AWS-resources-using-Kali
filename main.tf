# Creates VPC, subnets, custom route tables, internet gateway, Network ACL 
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "pentest_VPC"
  cidr = "10.0.0.0/16"

  # Availability zones
  azs = ["us-east-1a"]

  # Creating public subnet
  public_subnets       = ["10.0.101.0/24"]
  public_subnet_names  = ["pentest_public_subnet"]

  # Auto-assigns public IPv4 address for instances launched in public subnets to ensure they are internet accessible.
  map_public_ip_on_launch = true

  # Disable creation of default security group
  manage_default_security_group = false

  tags = {
    Terraform   = "true"
    Environment = "testing"
  }
}

resource "aws_instance" "vulnerable_ec2" {
  ami                    = "ami-06b21ccaeff8cd686" # Amazon AMI
  instance_type          = "t2.nano"
  subnet_id              = module.vpc.public_subnets[0] # Creates instance in first available public VPC subnet
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  key_name               = "test-key"        # Key name for ssh

  # # Running script to install apache, mysql
  # user_data = <<-EOF
  #             #!/bin/bash
  #             apt-get update
  #             apt-get install -y apache2 #mysql-server
  #             systemctl start apache2
  #             systemctl enable apache2
              
  #             # # Configure MySQL to accept remote connections (vulnerable configuration)
  #             # # Listening on all IP addresses
  #             # sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
  #             # systemctl restart mysql
              
  #             # Create a test webpage
  #             echo "<html><body><h1>Vulnerable Test Server</h1></body></html>" > /var/www/html/index.html
  #             EOF

  tags = {
    Name = "vulnerable_ec2"
  }
}

# Output public ip for convenience
output "public_ip" {
  value = aws_instance.vulnerable_ec2.public_ip
}