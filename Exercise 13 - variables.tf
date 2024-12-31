variable "vpc_attributes" {
  description = "Contains VPC's CIDR block and name."
  type = object({
    cidr_block = string
    name       = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_attributes.cidr_block)) # Checks if the VPC CIDR block can have a CIDR mask.
    error_message = "Invalid VPC CIDR block."
  }
}

data "aws_availability_zones" "available" { # All of the available AZs.
  state = "available"
}

variable "subnet_attributes" {
  description = <<EOT
  "Contains configuration on subnets: 
  cidr_block        : The subnet's CIDR block
  az                : The subnet's availability zone
  Public            : Whether subnet it public or private (default is private)
  EOT 
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false) # An optional variable to set to subnet. If not set to true, then the subnet is private.
  }))

  validation {
    condition     = alltrue([for cidr in values(var.subnet_attributes) : can(cidrnetmask(cidr.cidr_block))]) # Checks if the subnets' CIDR block can have a CIDR mask.
    error_message = "Invalid subnet CIDR block."
  }
}