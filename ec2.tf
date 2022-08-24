resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Allow HTTPS"
  vpc_id      = aws_vpc.Terra.id

  ingress {
    description      = "HTTPS inbound"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

 ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "webserver"
  }
}

locals {
  instance-userdata = <<EOF
#!/bin/bash
export PATH=$PATH:/usr/local/bin
which nmap >/dev/null
if [ $? -ne 0 ];
then
  echo 'NMAP NOT PRESENT'
  if [ -n "$(which yum)" ]; 
  then
    yum install -y nmap
  else 
    apt-get -y update && apt-get -y install nmap
  fi
else 
  echo 'NMAP ALREADY PRESENT'
fi
EOF
}

resource "aws_instance" "compromisedec2" {
  ami           = "ami-2757f631"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.publicsubnets.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  associate_public_ip_address = "true"
  key_name = "badguyec2"
  user_data_base64 = "${base64encode(local.instance-userdata)}"
  tags = {
    "Name" = "compromisedec2"
  }
}

resource "aws_instance" "scanmeec2" {
  ami           = "ami-2757f631"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.publicsubnets.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  associate_public_ip_address = "true"
  key_name = "badguyec2"
  tags = {
    "Name" = "scanmeec2"
  }
}