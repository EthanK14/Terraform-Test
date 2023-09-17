provider "aws" {
    region = "us-east-1"
}

# create a vpc

resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "Production"
    }
}

#create a internet gateway

resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.prod-vpc.id
  
}

resource "aws_route_table" "prod-route-tabel" {
    vpc_id = aws_vpc.prod-vpc.id
    
    # these set the default route to the internet gateway
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
    }

    route { 
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gateway.id
    }

    tags = {
        Name = "Prod"
    }

    
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    
    tags = {
        Name = "Prod-Subnet"
    }
}

# associate subnet with gateway (in aws it is assiciating the subnet with the internet route table) 
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.prod-route-tabel.id
  
}

# create a security group to allow port 22, 80, 443

resource "aws_security_group" "allow_web" {
    name = "allow_web_traffic"
    description = "Allow web traffic"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        
        }
    

    tags = {
        Name = "allow_web"
    }
  
}

#create a network interface with an ip in the subnet that was created earlier

resource "aws_network_interface" "web_server_nic" {
    subnet_id = aws_subnet.subnet-1.id
    private_ips = [ "10.0.1.50"]
    security_groups = [aws_security_group.allow_web.id]
  
}

# assing it a public elastic ip

resource "aws_eip" "one" {
    vpc = true
    network_interface = aws_network_interface.web_server_nic.id
    associate_with_private_ip = "10.0.1.50"
    depends_on = [aws_internet_gateway.gateway]

}

# create ubuntu apache server

resource "aws_instance" "web-server-instance" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "test-ubuntu"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.web_server_nic.id
    }
    
    # how to get a server to actually run commands on startup

    user_data = <<-EOF
        =!/bin/bash
        sudo apt update -y
        sudo apt install apache2 -y
        sudo systemctl start apache2
        sudo bash -c "echo your very first web server > /var/www/html/index/html"
        EOF
}