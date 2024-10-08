	# Specify the AWS provider

provider "aws" {

  region = "us-east-2"  # Replace with your desired region

}


# Define the key pair

resource "aws_key_pair" "my_key" {

  key_name   = "my-key"

  public_key = file("~/.ssh/id_rsa.pub")  # Path to your public key

}

data "aws_ami" "latest_amazon_linux" {

 most_recent = true 

owners = ["amazon"] 

filter {

 name = "name" 

values = ["amzn2-ami-hvm-*-x86_64-gp2"] 

}

 } 
# Define the security group allowing SSH traffic

resource "aws_security_group" "allow_ssh" {

  name        = "allow_ssh"

  description = "Allow SSH inbound traffic"

  

  ingress {

    from_port   = 22

    to_port     = 22

    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere, you can restrict this

  }


  egress {

    from_port   = 0

    to_port     = 0

    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}


# Define the EC2 instance

resource "aws_instance" "my_ec2" {

  ami           = data.aws_ami.latest_amazon_linux.id  # Amazon Linux 2 AMI (change according to region)

  instance_type = "t2.micro"               # Free tier instance type


  key_name      = aws_key_pair.my_key.key_name

  security_groups = [aws_security_group.allow_ssh.name]


  tags = {

    Name = "MyEC2Instance"

  }

}


# Create an S3 bucket

resource "aws_s3_bucket" "example" {
  bucket = "my-tf-example-bucket1"
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

# Output the public IP of the EC2 instance

output "ec2_public_ip" {

  value = aws_instance.my_ec2.public_ip

}

