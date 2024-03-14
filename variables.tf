variable "vpc_cidr_block" {
  default = "10.20.0.0/16"
}

variable "public_subnet_1_cidr" {
  default = "10.20.1.0/24"
}

variable "public_subnet_2_cidr" {
  default = "10.20.2.0/24"
}

variable "private_subnet_1_cidr" {
  default = "10.20.3.0/24"
}

variable "private_subnet_2_cidr" {
  default = "10.20.4.0/24"
}

variable "public_subnet_1_az" {
  type    = string
  default = "us-east-1a"
}

variable "public_subnet_2_az" {
  type    = string
  default = "us-east-1b"
}

variable "private_subnet_1_az" {
  type    = string
  default = "us-east-1a"
}

variable "private_subnet_2_az" {
  type    = string
  default = "us-east-1b"
}

variable "ec2_ami_id" {
  type    = string
  default = "ami-0cd59ecaf368e5ccf" # Insira aqui o ID da AMI desejada
}

variable "instance_type" {
  default = "t2.micro"
}
