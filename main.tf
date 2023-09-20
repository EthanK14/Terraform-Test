provider "aws" {
    region = "us-east-1"
}

# create ubuntu apache server

resource "aws_instance" "web-server-instance" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "test-ubuntu"

    #network_interface {
    #  device_index = 0
    #  network_interface_id = aws_network_interface.web_server_nic.id
    #}
    
    # how to get a server to actually run commands on startup

    user_data = <<-EOF
        =!/bin/bash
        sudo apt update -y
        sudo apt install apache2 -y
        sudo systemctl start apache2
        sudo bash -c "echo your very first web server > /var/www/html/index/html"
        EOF

      
}


# create the client side vpn cpnnection to vpc




# Creating Windows istance



resource "aws_instance" "windows-server-1" {
    ami = "ami-0be0e902919675894"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "windows-server"

    tags = {
      Name = "Windows Server DB"
    }

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.ws1.id
    }


    provisioner "local-exec" {
      command = "s1.ps1"
      interpreter = ["PowerShell", "-Command"]

      
    }

}


resource "aws_instance" "windows-server-2" {
  ami = "ami-0be0e902919675894"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "windows-server"

    tags = {
      Name = "Windows Server DB"
    }

    network_interface {
      device_index = 1
      network_interface_id = aws_network_interface.ws2.id
    }

}

resource "aws_instance" "windows-server-3" {
  ami = "ami-0be0e902919675894"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "windows-server"

    tags = {
      Name = "Windows Server DB"
    }

    network_interface {
      device_index = 1
      network_interface_id = aws_network_interface.ws3.id
    }

}

resource "aws_instance" "windows-server-4" {
  ami = "ami-0be0e902919675894"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"

    key_name = "windows-server"

    tags = {
      Name = "Windows Server DB"
    }

    network_interface {
      device_index = 1
      network_interface_id = aws_network_interface.ws4.id
    }

}


