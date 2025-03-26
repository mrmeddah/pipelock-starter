resource "aws_db_instance" "metabase" {  
  identifier             = "metabase-prod"  
  engine                = "postgres"  
  engine_version        = "13.7"  
  instance_class        = "db.t3.micro"  
  allocated_storage     = 20  
  storage_encrypted     = true  
  username              = var.db_username  
  password              = var.db_password 
  db_subnet_group_name  = aws_db_subnet_group.metabase.name  
  vpc_security_group_ids = [aws_security_group.rds.id]  
  skip_final_snapshot   = true  
  multi_az              = false   
}  