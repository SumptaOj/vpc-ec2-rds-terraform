# ASG, ALB, EC2, RDS in Custom VPC Using Terraform

Setting up a highly available sample PHP web service with Autoscaling, Application Load
Balancer, EC2, RDS in custom VPC using Terraform. 

How to accomplish these tasks:

- Create a custom VPC.
- Create an Internet Gateway and attach it to the VPC.
- Create public subnets (EC2) and private subnets (RDS).
- Create 2 route tables: 1 public and 1 private.
- Create security Group for EC2 , ALB and RDS.
- Create Launch template and Auto Scaling Group.
- Create Target group , ALB and ALB listener.
- Create RDS DB subnet group, DB parameter group and  RDS Instance.






