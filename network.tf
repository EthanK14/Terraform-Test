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

# none pubic facing subnet
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    
    tags = {
        Name = "Prod-Subnet"
    }
}

#subnet for windows instance public facing
resource "aws_subnet" "subnet-2" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"

    tags = {
      Name = "Public Facing subnet"
    }
    map_public_ip_on_launch = true

}

# associate subnet with gateway (in aws it is assiciating the subnet with the internet route table) 
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.prod-route-tabel.id
  
}

# create route table for windows server subnet-2
resource "aws_route_table_association" "windows" {
  subnet_id = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.prod-route-tabel.id
}

# create a security group to allow port 22, 80, 443, 3389, 5985

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
    
    #for windows instance
    ingress {
        description = "RDP acesss"
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "WinRM Access"
        from_port = 5986
        to_port = 5986
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_web"
    }
  
}

#create a network interface with an ip in the subnet that was created earlier

# resource "aws_network_interface" "web_server_nic" {
#     subnet_id = aws_subnet.subnet-1.id
#     private_ips = [ "10.0.1.50"]
#     security_groups = [aws_security_group.allow_web.id]
  
# }


# creating network interface for windows server
resource "aws_network_interface" "ws1" {
    subnet_id = aws_subnet.subnet-2.id
    private_ips = [ "10.0.2.10"]
    security_groups = [aws_security_group.allow_web.id]
    
}

resource "aws_network_interface" "ws2" {
    subnet_id = aws_subnet.subnet-2.id
    private_ips = ["10.0.2.20"]
    security_groups = [aws_security_group.allow_web.id]
}

resource "aws_network_interface" "ws3" {
    subnet_id = aws_subnet.subnet-2.id
    private_ips = ["10.0.2.30"]
    security_groups = [aws_security_group.allow_web.id]
}

resource "aws_network_interface" "ws4" {
    subnet_id = aws_subnet.subnet-2.id
    private_ips = ["10.0.2.40"]
    security_groups = [aws_security_group.allow_web.id]
}

resource "aws_network_interface" "deb-server" {
    subnet_id = aws_subnet.subnet-2.id
    private_ips = ["10.0.2.50"]
    security_groups = [aws_security_group.allow_web.id]
}

resource "aws_network_interface" "ws6" {
    subnet_id = aws_subnet.subnet-2.id
    private_ips = ["10.0.2.60"]
    security_groups = [aws_security_group.allow_web.id]
}


# assing it a public elastic ip for ununtu webserver

resource "aws_eip" "one" {
    vpc = true
    network_interface = aws_network_interface.db-server.id
    associate_with_private_ip = "10.0.1.60"
    depends_on = [aws_internet_gateway.gateway]

}