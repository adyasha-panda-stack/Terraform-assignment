
provider "aws" {
  region = "ap-south-1"
}

variable "instance_type" {
  default = "t3.small"
}

resource "aws_instance" "web" {
  ami           = "ami-0e38835daf6b8a2b9"
  instance_type = var.instance_type


  tags = {
    Name = "web-server"
  }
}
