output "availability_zones" {
  description = "All of the available AZs."
  value       = data.aws_availability_zones.available
}

output "understander_output" {
  description = "This output is used to visualize this project's lengthy coding."
  value       = can(cidrnetmask(var.vpc_attributes.cidr_block))
}

output "vpc_id" {
  description = "The ID of the created VPCs."
  value       = aws_vpc.local_modules_vpc.id
}

output "public_subnets" {
  description = "Important info on the created public subnets."
  value = { for key in keys(local.public_subnets) : key => {
    subnet_id  = aws_subnet.local_modules_subnet[key].id
    az         = aws_subnet.local_modules_subnet[key].availability_zone
    cidr_block = aws_subnet.local_modules_subnet[key].cidr_block
    }
  }
}

output "private_subnets" {
  description = "Important info on the created private subnets."
  value = { for key in keys(local.private_subnets) : key => {
    subnet_id  = aws_subnet.local_modules_subnet[key].id
    az         = aws_subnet.local_modules_subnet[key].availability_zone
    cidr_block = aws_subnet.local_modules_subnet[key].cidr_block
    }
  }
}