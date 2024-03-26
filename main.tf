# bloco inicial padrão

terraform {
  required_version = "1.7.4" # versão do terraform
  backend "local" {          # local para salvar o arquivo
    path = "terraform.tfstate"
  }
}


resource "aws_vpc" "main-vpc" { # recurso e nome do recurso no arquivo terraform
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "vpc-desafio"
  }
}

resource "aws_internet_gateway" "gate-net" {
  vpc_id = aws_vpc.main-vpc.id # para vpc id, recurso.nome no tf.id

  tags = {
    Name = "gate-net-desafio"
  }
}
resource "aws_subnet" "sub_net_pa" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.public_subnet_1_az

  tags = {
    Name = "Pub-a"
  }
  map_public_ip_on_launch = true
}
resource "aws_subnet" "sub_net_pb" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.public_subnet_2_az

  tags = {
    Name = "Pub-B"
  }
  map_public_ip_on_launch = true # habiltando ip publico ao inicializar a sub net
}

resource "aws_subnet" "subs-pva" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.private_subnet_1_az

  tags = {
    Name = "Priv-a"
  }
}
resource "aws_subnet" "sub-pvb" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.private_subnet_2_az

  tags = {
    Name = "Priv-B"
  }
}

resource "aws_route_table" "rota_public" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Rota_publica_1"
  }
}

resource "aws_route" "rota_gate_net" {
  route_table_id         = aws_route_table.rota_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gate-net.id

}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.sub_net_pa.id
  route_table_id = aws_route_table.rota_public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.sub_net_pb.id
  route_table_id = aws_route_table.rota_public.id
}

resource "aws_eip" "ip_elastico" {
  tags = {
    Name = "Ip_elastico_1"

  }
}



resource "aws_nat_gateway" "nat_gate_1" {
  allocation_id = aws_eip.ip_elastico.id
  subnet_id     = aws_subnet.sub_net_pa.id

  tags = {
    Name = "NatGat1"
  }
}


resource "aws_route_table" "rota_privada" {
  vpc_id = aws_vpc.main-vpc.id
  tags = {
    Name = "Rota_privada_1"
  }
}

resource "aws_route" "rota_nat_gate_net" {
  route_table_id         = aws_route_table.rota_privada.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gate_1.id

}

resource "aws_route_table_association" "privada_subnet_1" {
  subnet_id      = aws_subnet.subs-pva.id
  route_table_id = aws_route_table.rota_privada.id
}

resource "aws_route_table_association" "privada_subnet_2" {
  subnet_id      = aws_subnet.sub-pvb.id
  route_table_id = aws_route_table.rota_privada.id
}


resource "aws_security_group" "my_security_group" {
  name        = "Meu-grupo-de-seguranca"
  description = "My Security Group for SSH, HTTP, and HTTPS"
  vpc_id      = aws_vpc.main-vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.xxx.xxx/32"] # Substitua pelo bloco CIDR da sua rede para SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite HTTP de qualquer lugar
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite HTTPS de qualquer lugar
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                             # todos os protocolos
    cidr_blocks = ["0.0.0.0/0"]   # permite saída para qualquer lugar
 
}

resource "aws_instance" "teste_ec2" {
  ami           = var.ec2_ami_id
  instance_type = var.instance_type # Tipo de instância desejado
  subnet_id     = aws_subnet.sub_net_pa.id

  key_name               = "CHAVE-PROJETO" # Substitua pelo nome da sua chave existente
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  tags = {
    Name = "EC2-DESAFIO"
  }
  user_data = base64encode(templatefile("${path.module}/templatefile/setup.sh.tp1", {
    db_name     = aws_db_instance.meu_db.db_name
    db_username = aws_db_instance.meu_db.username
    db_password = aws_db_instance.meu_db.password
    db_address  = aws_db_instance.meu_db.address
  }))


}

resource "aws_security_group" "my_db_gp_seguranca" {
  name        = "mydbsecuritygroup"
  description = "My DB Security Group"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir acesso de qualquer lugar. Apenas para testes
  }
}

resource "aws_db_instance" "meu_db" {
  identifier             = "mydbinstance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7.44"
  instance_class         = "db.t2.micro"
  username               = "teste"
  password               = "teste123"
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.meu_gp_subnet.id
  vpc_security_group_ids = [aws_security_group.my_db_gp_seguranca.id]

}

resource "aws_db_subnet_group" "meu_gp_subnet" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subs-pva.id, aws_subnet.sub-pvb.id]
}

resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id]
  subnets            = [aws_subnet.sub_net_pa.id, aws_subnet.sub_net_pb.id]

  enable_deletion_protection = false

  tags = {
    Name = "my-load-balancer"
  }
}

resource "aws_lb_listener" "meu_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main-vpc.id 

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group_attachment" "meu_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.teste_ec2.id
}


resource "aws_launch_template" "meu-template" {
  name = "meu-template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  network_interfaces {

    security_groups       = [aws_security_group.my_security_group.id]
  }

  image_id = "ami-0cd59ecaf368e5ccf" # Substitua pela AMI da sua instância
  instance_type = "t2.micro" # Substitua pelo tipo de instância da sua instância
  key_name = "CHAVE-PROJETO" # Substitua pelo nome do seu par de chaves

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "example-instance"
    }
  }
}

resource "aws_autoscaling_group" "meu-autoscaling-gp" {
  name                      = "Autoscaling Group"
  vpc_zone_identifier       = [aws_subnet.subs-pva.id, aws_subnet.sub-pvb.id]
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 240
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.my_target_group.id]

  launch_template {
    id      = aws_launch_template.meu-template.id
    version = aws_launch_template.meu-template.latest_version
  }
}

resource "aws_autoscaling_policy" "scaleup" {
  name                   = "Scale Up"
  autoscaling_group_name = aws_autoscaling_group.meu-autoscaling-gp.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "180"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scaledown" {
  name                   = "Scale Down"
  autoscaling_group_name = aws_autoscaling_group.meu-autoscaling-gp.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "180"
  policy_type            = "SimpleScaling"
}

