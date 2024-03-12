terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    #mysql = {
    #  source  = "winebarrel/mysql"
    #  version = "~> 1.10.2"
    #}
  }
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

# 1. Create an AWS VPC
resource "aws_vpc" "tf_env_vpc" {
  cidr_block = var.CIDR_BLOCK
  tags = {
    Name        = "tf_env_vpc"
    description = "Created by Terraform, Date Created: ${local.current_timestamp}"
  }
}

# 2. Create an AWS Internet Gateway
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_env_vpc.id
  tags = {
    Name = "tf_igw"
  }
}

# 3. Create Egress Internet Gateway
resource "aws_egress_only_internet_gateway" "egw" {
  vpc_id = aws_vpc.tf_env_vpc.id

  tags = {
    Name = "tf-egress-gw"
  }
}

# 3. Create an AWS Route Table
resource "aws_route_table" "tf_env_rt" {
  vpc_id = aws_vpc.tf_env_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.egw.id
  }

  tags = {
    Name = "tf-env-rt"
  }
}

# 4. Create an AWS Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.tf_env_vpc.id
  cidr_block        = "10.10.10.0/24"
  availability_zone = var.AWS_AZ_ONE

  tags = {
    Name = "tf-env-subnet-1"
  }
}

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.tf_env_vpc.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = var.AWS_AZ_TWO

  tags = {
    Name = "tf-env-subnet-2"
  }
}

# 5. Create a AWS Route Table Association
resource "aws_route_table_association" "route_table_assoc" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.tf_env_rt.id
}

# 6. Create RDS
resource "aws_db_instance" "tf_mysql_instance" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  #version 8.0.11
  engine_version         = "8.0.28"
  instance_class         = "db.t2.medium"
  username               = var.DB_USER
  password               = var.DB_PW
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.tf_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.tf_sg_allow_web.id]
  skip_final_snapshot    = true

  tags = {
    Name = "tf-rds-mysql-instance"
  }

}

resource "aws_db_subnet_group" "tf_db_subnet_group" {
  name       = "tf-db-sql-subnet-group"
  subnet_ids = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]

  tags = {
    Name = "tf rds mysql SubnetGroup"
  }
}

# 7. Create a Security Group
resource "aws_security_group" "tf_sg_allow_web" {
  name        = "allow_web_traffic"
  description = "Created by Terraform, Allow Web inbound traffic"
  vpc_id      = aws_vpc.tf_env_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom TCP for port 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust CIDR blocks as per your requirement
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.10.10.0/24"] # Adjust to match your subnet or specific IPs
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tf_sg_allow_web"
  }
}


# 8. Create an AWS Network Interface

resource "aws_network_interface" "tf-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.10.10.15"]
  security_groups = [aws_security_group.tf_sg_allow_web.id]

  tags = {
    Name = "tf-nic"
  }

}

# 9. Assign an elastic IP to the network interface created in Step 8
resource "aws_eip" "tf-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.tf-nic.id
  associate_with_private_ip = "10.10.10.15"
  depends_on                = [aws_internet_gateway.tf_igw]
  tags = {
    Name = "tf-elastic-ip"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# 10. Create a AWS EC2 instance
resource "aws_instance" "tf-web-server-instance" {
  ami               = "ami-053b0d53c279acc90"
  instance_type     = var.AWS_INSTANCE_TYPE
  availability_zone = var.AWS_AZ_ONE
  key_name          = aws_key_pair.deployer.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.tf-nic.id
  }

  provisioner "file" {
    source      = "~/Documents/GitHub/fluwd_env_poc/dataload.sh"
    destination = "/home/ubuntu/dataload.sh"

    connection {
      type        = "ssh"
      user        = var.AWS_SSH_USER
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  provisioner "file" {

    source      = "~/Documents/GitHub/fluwd_env_poc/django_dependencies.sh"
    destination = "/home/ubuntu/django_dependencies.sh"

    connection {
      type        = "ssh"
      user        = var.AWS_SSH_USER
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip

    }
  }

  provisioner "file" {

    source      = "~/Documents/GitHub/fluwd_env_poc/requirement.txt"
    destination = "/home/ubuntu/requirement.txt"

    connection {
      type        = "ssh"
      user        = var.AWS_SSH_USER
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip

    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.AWS_SSH_USER
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    inline = [
      "git clone https://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:x-oauth-basic@github.com/heraldblrt/fluwd_automation.git",
      "chmod +x django_dependencies.sh ",
      "chmod +x dataload.sh ",
      "echo 'export EC2_PUBLIC_IP=${aws_eip.tf-eip.public_ip}' >> ~/.bashrc",
      "echo 'export DB_NAME=${var.DB_NAME}' >> ~/.bashrc",
      "echo 'export DB_HOST=${aws_db_instance.tf_mysql_instance.endpoint}' >> ~/.bashrc",
      "echo 'export DB_PORT=${var.DB_PORT}' >> ~/.bashrc",
      "echo 'export DB_USER=${var.DB_USER}' >> ~/.bashrc",
      "echo 'export DB_PW=${var.DB_PW}' >> ~/.bashrc",
      "/bin/bash -c 'source ~/.bashrc'",
    ]
  }

  user_data = <<EOF
#!/bin/bash

sudo apt-get update

sudo apt-get install python3 python3-pip git -y

sudo apt install python3.10-venv -y

sudo apt install pkg-config 

sudo apt install default-libmysqlclient-dev build-essential -y

sudo apt install mysql-server -y

EOF

  tags = {
    Name = "tf-web-server"
  }
}

output "instance_ip" {
  value       = aws_instance.tf-web-server-instance.public_ip
  description = "EC2 Public IP"
}

output "created_date" {
  value = local.current_timestamp
}

output "mysql_endpoint" {
  value       = aws_db_instance.tf_mysql_instance.endpoint
  description = "The connection endpoint for the database."
}
