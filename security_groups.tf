resource "aws_security_group" "grupo_seguranca" {
  name        = "meu-grupo-seguranca"
  description = "grupo-seguranca-ec2"
  vpc_id      = aws_vpc.vpc_principal.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_cidr]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_cidr]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_grupo_seguranca" {
  name        = "db-grupo-seguranca"
  description = "meu grupo de seguranca para banco de dados"
  vpc_id      = aws_vpc.vpc_principal.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Somente para testes e estudos! jamais fazer isso.
  }
}