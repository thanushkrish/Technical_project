data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# --- VPC ---
resource "aws_vpc" "my-vpc2" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "tf-myvpc2-main"
  }
}

# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.my-vpc2.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = length(var.availability_zone) > 0 ? var.availability_zone : null
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet-public"
  }
}

# --- Private Subnet ---
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.my-vpc2.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = length(var.availability_zone) > 0 ? var.availability_zone : null
  tags = {
    Name = "tf-subnet-private"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc2.id
  tags = {
    Name = "tf-igw"
  }
}

# --- Public Route Table (for public subnet) ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my-vpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "tf-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}



# --- Security Group: allow SSH, HTTP, HTTPS from anywhere (tweak as needed) ---
resource "aws_security_group" "instance_sg" {
  name        = "tf-instance-sg"
  description = "Allow SSH/HTTP/HTTPS"
  vpc_id      = aws_vpc.my-vpc2.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]   # <--- tighten this to your IP for production
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-instance-sg"
  }
}

# --- EC2 Instance (in public subnet so you can SSH directly) ---
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "tf-ec2-web"
  }

  # optional user_data to install nginx quickly
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "Hello from Terraform-deployed instance" > /var/www/html/index.html
              EOF
}

# --- EBS Volume (3 GB) and attachment to the EC2 instance as /dev/sdf ---
# Size set to 3 (GB) as requested
resource "aws_ebs_volume" "extra" {
  availability_zone = aws_instance.web.availability_zone
  size              = 3   # 3 GB exact. (Digit-by-digit: 3)
  tags = {
    Name = "tf-extra-ebs-3gb"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.extra.id
  instance_id = aws_instance.web.id
  force_detach = true
}

# --- S3 Bucket ---
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  

  tags = {
    Name = "tf-s3-bucket"
  }

  
}

# --- Outputs ---
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my-vpc2.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.private.id
}

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ebs_volume_id" {
  description = "ID of the extra 3GB EBS volume"
  value       = aws_ebs_volume.extra.id
}

output "s3_bucket" {
  description = "S3 bucket"
  value       = aws_s3_bucket.bucket.bucket
}
