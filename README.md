# terraform-aws-networking-tf-course

This networking module was created during Lauro Mueller's Terraform course.
This module deals with creation of VPCs and Subnets which can be public or private.

Sample Usage:
```
module "vpc" {
  source = "./modules/networking"

  vpc_attributes = {
    cidr_block = "10.0.0.0/16"
    name       = "your_vpc"
  }

  subnet_attributes = {
    subnet_1 = {
      cidr_block = "10.0.0.0/24"
      az         = "ap-southeast-1a"
    }
    subnet_2 = {
      cidr_block = "10.0.2.0/24"
      az         = "ap-southeast-1c"
      public     = true
    }
  }
}
```