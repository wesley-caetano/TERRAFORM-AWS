variable "vpc_cidr_block" {
  default = "10.20.0.0/16"
}

variable "subnet_publica_a_cidr" {
  default = "10.20.1.0/24"
}

variable "subnet_publica_b_cidr" {
  default = "10.20.2.0/24"
}

variable "subnet_privada_a_cidr" {
  default = "10.20.3.0/24"
}

variable "subnet_privada_b_cidr" {
  default = "10.20.4.0/24"
}

variable "az_a" {
  default = "us-east-1a"
}

variable "az_b" {
  default = "us-east-1b"
}

variable "meu_ip_cidr" {
  default = "XXX.XXX.XXX.XXX.XX"
}

variable "key-name" {
  default = "SUA-CHAVE"
}

variable "tipo-instancia" {
  default = "t2.micro"
}

variable "ec2_ami_id" {
  default = "ami-0cd59ecaf368e5ccf"
}
