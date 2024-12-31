variable "vpc_attributes" {
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