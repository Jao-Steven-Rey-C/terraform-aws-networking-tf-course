locals {
  public_subnets  = { for pen, pineapple in var.subnet_attributes : pen => pineapple if pineapple.public }
  private_subnets = { for pen, pineapple in var.subnet_attributes : pen => pineapple if !pineapple.public }
}

resource "aws_vpc" "local_modules_vpc" {
  cidr_block = var.vpc_attributes.cidr_block

  tags = {
    Name = var.vpc_attributes.name
  }
}

resource "aws_subnet" "local_modules_subnet" {
  for_each          = var.subnet_attributes
  vpc_id            = aws_vpc.local_modules_vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  lifecycle {
    precondition {
      condition = contains(data.aws_availability_zones.available.names, each.value.az)
      # "EOT" allows and encapsulates multiline strings. Error messages must be clear and user-friendly for whoever will use the module.
      error_message = <<-EOT
      The AZ "${each.value.az}" provided for the subnet "${each.key}" is invalid. # Says which subnet has the incorrect AZ.

      The applied AWS region "${data.aws_availability_zones.available.id}" # Supports the following AZs: # Says the available AZs for the specific region.
      [${join(", ", data.aws_availability_zones.available.names)}]
      EOT
    }
  }

  tags = {
    Name   = each.key                                 # Subnet name is all the keys of var.subnet_attributes.
    Public = each.value.public ? "Public" : "Private" # Checks each value of var.subnet_attributes. Returns "Public" if subnet is public else, returns "Private".
  }
}

resource "aws_internet_gateway" "local_modules_igw" {
  count  = length(local.public_subnets) > 0 ? 1 : 0 # If there is more than 0 public subnets created, then 1 igw will be created. Else, none will be.
  vpc_id = aws_vpc.local_modules_vpc.id
}

resource "aws_route_table" "local_modules_rtb" {
  count  = length(local.public_subnets) > 0 ? 1 : 0 # If there is more than 0 public subnets created, then 1 rtb will be created. Else, none will be.
  vpc_id = aws_vpc.local_modules_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.local_modules_igw[0].id # Since there is only 1 igw, then points at igw[0].
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.local_modules_subnet[each.key].id # Points to all the public subnets.
  route_table_id = aws_route_table.local_modules_rtb[0].id      # Since there is only 1 rtb, then points at rtb[0].
}