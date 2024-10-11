resource "aws_db_instance" "default" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  identifier        = "mydb"
  username          = "dbuser"
  password          = "dbpassword"

}

