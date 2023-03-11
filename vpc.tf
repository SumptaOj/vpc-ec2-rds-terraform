// Create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = var.project_name
}

// Create an Internet Gateway and attach it to the vpc
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = var.project_name
}

// create public subnet1 for ec2 webserver
resource "aws_subnet" "web_public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet1
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = var.project_name

}

// create public subnet2 for ec2 webserver
resource "aws_subnet" "web_public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet2
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = var.project_name


}


// create private subnet1 for db instance
resource "aws_subnet" "db_private_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet1
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = var.project_name

}

// create private subnet2 for db instance
resource "aws_subnet" "db_private_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet2
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = var.project_name

}

// create a public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = var.project_name
}

// Associate the public subnets to the route table
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.web_public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

// Associate the public subnets to the route table
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.web_public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

// Create a private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = var.project_name
}

// Associate the private subnets to the route table
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.db_private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

// Associate the private subnets to the route table
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.db_private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

// Create security group for ec2 webserver
resource "aws_security_group" "web_sg" {
  name   = "web_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    description = "Allow all traffic from HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all traffic from HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.project_name
}

// Create security group for db instance
resource "aws_security_group" "db_sg" {
  name   = "db_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description     = "Allow only MySQL traffic from web_sg "
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = var.project_name
}