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
  ami                    = "ami-06b21ccaeff8cd686" # Amazon Linux 2023 AMI
  instance_type          = "t2.nano"
  subnet_id              = module.vpc.public_subnets[0] # Creates instance in first available public VPC subnet
  vpc_security_group_ids = [aws_security_group.vulnerable_sg.id]
  key_name               = "weak-key"        # Key name for ssh

  # Running script to install apache, mysql
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              
              # Install Apache web server
              dnf install -y httpd
              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd

              # Install MySQL, MariaDB
              dnf install -y mariadb105-server mariadb105
              
              # Configure MySQL to accept remote connections from anywhere
              # Uses sed to set bind-address to 0.0.0.0, uncommenting if needed
              sed -i 's/^#bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf

              # Start and enable MariaDB
              systemctl start mariadb
              systemctl enable mariadb

              # Create a test webpage
              echo "<html><body><h1>Vulnerable Test Server</h1></body></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "vulnerable_ec2"
  }
}

# Output public ip for convenience
output "public_ip" {
  value = aws_instance.vulnerable_ec2.public_ip
}