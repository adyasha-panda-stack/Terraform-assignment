resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-0e38835daf6b8a2b9"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = false

 tags = {
    Name = "web-server-priv"
  }
}
