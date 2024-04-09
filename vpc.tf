resource "aws_vpc" "vpc_principal" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "vpc-projeto"
  }
}

resource "aws_subnet" "subnet_publica_a" {
  vpc_id            = aws_vpc.vpc_principal.id
  cidr_block        = var.subnet_publica_a_cidr
  availability_zone = var.az_a

  tags = {
    Name = "subnet-publica-a"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_publica_b" {
  vpc_id            = aws_vpc.vpc_principal.id
  cidr_block        = var.subnet_publica_b_cidr
  availability_zone = var.az_b

  tags = {
    Name = "subnet-publica-b"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_privada_a" {
  vpc_id            = aws_vpc.vpc_principal.id
  cidr_block        = var.subnet_privada_a_cidr
  availability_zone = var.az_a

  tags = {
    Name = "subnet-privada-a"
  }
}

resource "aws_subnet" "subnet_privada_b" {
  vpc_id            = aws_vpc.vpc_principal.id
  cidr_block        = var.subnet_privada_b_cidr
  availability_zone = var.az_b

  tags = {
    Name = "subnet-privada-b"
  }
}

resource "aws_internet_gateway" "gate_net" {
  vpc_id = aws_vpc.vpc_principal.id
  tags = {
    Name = "Gate-de-internet"
  }
}

resource "aws_route_table" "rota_publica" {
  vpc_id = aws_vpc.vpc_principal.id

  tags = {
    Name = "rota-publica"
  }
}

resource "aws_route" "rota_gate_net" {
  route_table_id         = aws_route_table.rota_publica.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gate_net.id
}

resource "aws_route_table_association" "publica_1" {
  subnet_id      = aws_subnet.subnet_publica_a.id
  route_table_id = aws_route_table.rota_publica.id
}
resource "aws_route_table_association" "publica_2" {
  subnet_id      = aws_subnet.subnet_publica_b.id
  route_table_id = aws_route_table.rota_publica.id
}

resource "aws_eip" "ip_elastico" {

  tags = {
    Name = "ip-elastico"
  }
}

resource "aws_nat_gateway" "nat_internet" {
  allocation_id = aws_eip.ip_elastico.id
  subnet_id     = aws_subnet.subnet_publica_a.id

  tags = {
    Name = "nat-internet"
  }
}

resource "aws_route_table" "rota_privada" {
  vpc_id = aws_vpc.vpc_principal.id

  tags = {
    Name = "rota-privada"
  }
}

resource "aws_route" "rota_nat" {
  route_table_id         = aws_route_table.rota_privada.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_internet.id
}

resource "aws_route_table_association" "privada-1" {
  subnet_id      = aws_subnet.subnet_privada_a.id
  route_table_id = aws_route_table.rota_privada.id
}

resource "aws_route_table_association" "privada-2" {
  subnet_id      = aws_subnet.subnet_privada_b.id
  route_table_id = aws_route_table.rota_privada.id
}