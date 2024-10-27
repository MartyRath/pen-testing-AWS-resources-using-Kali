# Provider configuration
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# VPC
resource "aws_vpc" "pentest_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "pentest-vpc"
    Environment = "testing"
  }
}