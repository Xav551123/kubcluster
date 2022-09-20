terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key = var.access_key 
  secret_key = var.secret_key
  region = var.AWS_REGION
}

# Create a VPC
resource "aws_vpc" "k8s-vpc" {
  cidr_block = "10.5.0.0/16"
  tags = {
        Name = "k8s-vpc"
    }
}


resource "aws_subnet" "k8s-public-subnet" {
    for_each = var.AWS_SUBNET
    vpc_id = aws_vpc.k8s-vpc.id
    cidr_block = "${each.value}"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "${each.key}"
    
}

resource "aws_internet_gateway" "k8s-igw" {
    vpc_id = "${aws_vpc.k8s-vpc.id}"
    tags = {
        Name = "ilki05gateway"
    }
}

resource "aws_route_table" "k8s-public-crt" {
    vpc_id = "${aws_vpc.k8s-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.k8s-igw.id}" 
    }
    
    tags = {
        Name = "k8s-public-crt"
    }
}

resource "aws_security_group" "k8s-sg" {
    vpc_id = "${aws_vpc.k8s-vpc.id}"
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
   
    tags = {
        Name = "k8s-sg"
    }
}

resource "aws_eks_cluster" "example" {
  name     = "mycluster"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
  }

depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}


