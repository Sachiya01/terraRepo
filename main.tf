#Create VPC 
resource "aws_vpc" "sachith_tf_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "sachith_tf_vpc"
  }
}

# Create Public subnet
resource "aws_subnet" "sachith_tf_pub_sub" {
  vpc_id                  = aws_vpc.sachith_tf_vpc.id
  cidr_block              = var.pub_sub_cidr
  availability_zone       = var.aws_az
  map_public_ip_on_launch = true
  tags = {
    Name = "sachith_tf_pub_sub"
  }
}

#Create Private subnet
resource "aws_subnet" "sachith_tf_pvt_sub" {
  vpc_id            = aws_vpc.sachith_tf_vpc.id
  cidr_block        = var.pvt_sub_cidr
  availability_zone = var.aws_az
  tags = {
    Name = "sachith_tf_pvt_sub"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "sachith_tf_igw" {
  vpc_id = aws_vpc.sachith_tf_vpc.id
  tags = {
    Name = "sachith_tf_igw"
  }
}

#Create EIP and NAT Gateway
resource "aws_eip" "sachith_tf_eip" {
  domain = "vpc"
  tags = {
    Name = "sachith_tf_eip"
  }

}

#Create NAT Gateway
resource "aws_nat_gateway" "sachith_tf_nat_gw" {
  allocation_id = aws_eip.sachith_tf_eip.id
  subnet_id     = aws_subnet.sachith_tf_pub_sub.id
  tags = {
    Name = "sachith_tf_nat_gw"
  }

}

#Create Public Route Table
resource "aws_route_table" "sachith_tf_pub_rt" {
  vpc_id = aws_vpc.sachith_tf_vpc.id
  tags = {
    Name = "sachith_tf_pub_rt"
  }

}

#Create Route to Internet Gateway
resource "aws_route" "sachith_tf_pub_rt_route" {
  route_table_id         = aws_route_table.sachith_tf_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.sachith_tf_igw.id
}

#Create Public Route Table Association
resource "aws_route_table_association" "sachith_tf_pub_rt_assoc" {
  subnet_id      = aws_subnet.sachith_tf_pub_sub.id
  route_table_id = aws_route_table.sachith_tf_pub_rt.id
}

#Create Private Route Table
resource "aws_route_table" "sachith_tf_pvt_rt" {
  vpc_id = aws_vpc.sachith_tf_vpc.id
  tags = {
    Name = "sachith_tf_pvt_rt"
  }
}
#Create Route to NAT Gateway    
resource "aws_route" "sachith_tf_pvt_rt_route" {
  route_table_id         = aws_route_table.sachith_tf_pvt_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.sachith_tf_nat_gw.id
}

#Create Private Route Table Association
resource "aws_route_table_association" "sachith_tf_pvt_rt_assoc" {
  subnet_id      = aws_subnet.sachith_tf_pvt_sub.id
  route_table_id = aws_route_table.sachith_tf_pvt_rt.id
}

#Create Public Security Group
resource "aws_security_group" "sachith_tf_pub_sg" {
  name        = "sachith_tf_pub_sg"
  description = "Security group for public subnet"
  vpc_id      = aws_vpc.sachith_tf_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 19082
    to_port     = 19082
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sachith_tf_pub_sg"
  }

}

#Create Private Security Group
resource "aws_security_group" "sachith_tf_pvt_sg" {
  vpc_id = aws_vpc.sachith_tf_vpc.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sachith_tf_pub_sg.id]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sachith_tf_pub_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "sachith_tf_pvt_sg"
  }
}


#Create Public EC2 Instance
resource "aws_instance" "sachith_tf_pub_instance" {
  ami                    = var.ami
  instance_type          = var.pub_instance_type
  subnet_id              = aws_subnet.sachith_tf_pub_sub.id
  key_name               = "tf_sachith"
  vpc_security_group_ids = [aws_security_group.sachith_tf_pub_sg.id]
  user_data              = file("userdata/pritunl.sh")

  tags = {
    Name     = "sachith_tf_pub_instance1"
    Duration = "Temporary"
    User     = "Sachith"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    tags = {
      Name     = "sachith_tf_pub_instance"
      Duration = "Temporary"
      User     = "Sachith"
    }
  }
}

#Create Private EC2 Instance
resource "aws_instance" "sachith_tf_pvt_instance" {

  ami                    = var.ami
  instance_type          = var.pvt_instance_type
  subnet_id              = aws_subnet.sachith_tf_pvt_sub.id
  key_name               = "tf_sachith"
  vpc_security_group_ids = [aws_security_group.sachith_tf_pvt_sg.id]
  user_data              = file("userdata/jenkins-ec2.sh")

  tags = {
    Name     = "sachith_tf_pvt_instance"
    Duration = "Temporary"
    User     = "Sachith"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    tags = {
      Name     = "sachith_tf_pvt_instance"
      Duration = "Temporary"
      User     = "Sachith"
    }
  }
}