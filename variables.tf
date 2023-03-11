variable "vpc_cidr" {
  description = "cidr block for the vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "common tags to be applied to all components."
  default = {
    Name = "ec2_rds_instance"
  }
}

variable "public_subnet1" {
  description = "cidr block for the public subnet1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet2" {
  description = "cidr block for the public subnet1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet1" {
  description = "cidr block for the public subnet1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet2" {
  description = "cidr block for the public subnet1"
  type        = string
  default     = "10.0.4.0/24"
}

variable "instance_type" {
  description = "type of instance type"
  default     = "t2.micro"
}

variable "my_ip" {
  description = "my IP address"
  type        = string
  sensitive   = true
}

variable "configuration" {
  description = "rds configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage       = 10
      engine                  = "mysql"
      engine_version          = "5.7"
      instance_class          = "db.t2.micro"
      maintenance_window      = "Fri:00:00-Fri:03:00"
      backup_window           = "10:00-11:30"
      backup_retention_period = 7
      storage_encrypted       = false
      skip_final_snapshot     = true
    }
  }
}

variable "db_name" {
  description = "Value of the regions"
  default     = "mysqldb"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Database administrator password"
  type        = string
  default     = "webserver-userdata99"
}
