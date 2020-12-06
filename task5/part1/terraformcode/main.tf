provider "aws"{
  region = "us-east-1"

}


resource "aws_instance" "udacity_ec2" {
  ami = "ami-00ddb0e5626798373"
  instance_type = "t2.micro"
  count = 4
  vpc_security_group_ids = ["sg-ae99a181"]

  tags = {
    Name = "Udacity T2"
  }
}

resource "aws_instance" "udacity_ec21" {
  ami = "ami-00ddb0e5626798373"
  instance_type = "m4.large"
  count = 2
  vpc_security_group_ids = ["sg-ae99a181"]
  tags = {
    Name = "Udacity M4"
  }
}

