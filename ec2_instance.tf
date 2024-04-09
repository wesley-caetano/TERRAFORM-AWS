

resource "aws_instance" "instancia-projeto" {
  ami           = var.ec2_ami_id
  instance_type = var.tipo-instancia
  subnet_id     = aws_subnet.subnet_publica_a.id

  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.grupo_seguranca.id]

  tags = {
    Name = "EC2-DESAFIO"
  }
  user_data = base64encode(templatefile("${path.module}/templatefile/setup.sh.tp2", {
    db_name     = aws_db_instance.data_base.db_name
    db_username = aws_db_instance.data_base.username
    db_password = aws_db_instance.data_base.password
    db_address  = aws_db_instance.data_base.address
  }))
}