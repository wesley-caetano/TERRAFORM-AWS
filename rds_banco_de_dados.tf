resource "aws_db_subnet_group" "subnet-db" {
  name       = "subnet-data-base"
  subnet_ids = [aws_subnet.subnet_privada_a.id, aws_subnet.subnet_privada_b.id]
}

resource "aws_db_instance" "data_base" {
  identifier             = "data-base"
  db_name                = "wordpress"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7.44"
  instance_class         = "db.t3.micro"
  username               = "rigel"
  password               = "rigel123"
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.subnet-db.id
  vpc_security_group_ids = [aws_security_group.db_grupo_seguranca.id]

}