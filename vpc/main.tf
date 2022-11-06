# set a local variable to tag resources with the terraform stack name
locals {
  stackName = "vpc-tf"
}

# create the VPC and assign enable IPv6 if set to true in input variables
resource "aws_vpc" "VPC" {
  cidr_block           = var.VPCCIDR
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.stackName}-VPC"
  }
}

# create internet gateway
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${local.stackName}-IGW"
  }
}

#create 3 elastic IP addresses for nat gateways to use
resource "aws_eip" "EIP1" {
  vpc = true
  depends_on = [
    aws_internet_gateway.IGW
  ]
}

resource "aws_eip" "EIP2" {
  vpc = true
  depends_on = [
    aws_internet_gateway.IGW
  ]
}

resource "aws_eip" "EIP3" {
  vpc = true
  depends_on = [
    aws_internet_gateway.IGW
  ]
}

# create 3 nat gateways and assign each one to a public subnet
resource "aws_nat_gateway" "NATGWPubSN1" {
  allocation_id = aws_eip.EIP1.id
  subnet_id     = aws_subnet.PubSN1.id

  tags = {
    Name = "${local.stackName}-NATGWPubSN1"
  }
}

resource "aws_nat_gateway" "NATGWPubSN2" {
  allocation_id = aws_eip.EIP2.id
  subnet_id     = aws_subnet.PubSN2.id

  tags = {
    Name = "${local.stackName}-NATGWPubSN2"
  }
}

resource "aws_nat_gateway" "NATGWPubSN3" {
  allocation_id = aws_eip.EIP3.id
  subnet_id     = aws_subnet.PubSN3.id

  tags = {
    Name = "${local.stackName}-NATGWPubSN2"
  }
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

# create 3 public subnets
resource "aws_subnet" "PubSN1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.PubSN1Cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.stackName}-PubSN1"
  }
}

resource "aws_subnet" "PubSN2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.PubSN2Cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.stackName}-PubSN2"
  }
}

resource "aws_subnet" "PubSN3" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = var.PubSN3Cidr
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true


  tags = {
    Name = "${local.stackName}-PubSN3"
  }
}

# create 3 private subnets
resource "aws_subnet" "PvtSN1" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.PvtSN1Cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${local.stackName}-PvtSN1"
  }
}

resource "aws_subnet" "PvtSN2" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.PvtSN2Cidr
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${local.stackName}-PvtSN2"
  }
}

resource "aws_subnet" "PvtSN3" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = var.PvtSN3Cidr
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "${local.stackName}-PvtSN3"
  }
}

resource "aws_route_table" "RTPubSN1" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "${local.stackName}-RTPubSN1"
  }
}

resource "aws_route_table" "RTPubSN2" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "${local.stackName}-RTPubSN2"
  }
}

resource "aws_route_table" "RTPubSN3" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "${local.stackName}-RTPubSN3"
  }
}

resource "aws_route_table" "RTPvtSN1" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGWPubSN1.id
  }

  tags = {
    Name = "${local.stackName}-RTPvtSN1"
  }
}

resource "aws_route_table" "RTPvtSN2" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGWPubSN2.id
  }

  tags = {
    Name = "${local.stackName}-RTPvtSN2"
  }
}

resource "aws_route_table" "RTPvtSN3" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATGWPubSN3.id
  }

  tags = {
    Name = "${local.stackName}-RTPvtSN3"
  }
}

resource "aws_route_table_association" "RTAssociationPubSN1" {
  subnet_id      = aws_subnet.PubSN1.id
  route_table_id = aws_route_table.RTPubSN1.id
}

resource "aws_route_table_association" "RTAssociationPubSN2" {
  subnet_id      = aws_subnet.PubSN2.id
  route_table_id = aws_route_table.RTPubSN2.id
}

resource "aws_route_table_association" "RTAssociationPubSN3" {
  subnet_id      = aws_subnet.PubSN3.id
  route_table_id = aws_route_table.RTPubSN3.id
}

resource "aws_route_table_association" "RTAssociationPvtSN1" {
  subnet_id      = aws_subnet.PvtSN1.id
  route_table_id = aws_route_table.RTPvtSN1.id
}

resource "aws_route_table_association" "RTAssociationPvtSN2" {
  subnet_id      = aws_subnet.PvtSN2.id
  route_table_id = aws_route_table.RTPvtSN2.id
}

resource "aws_route_table_association" "RTAssociationPvtSN3" {
  subnet_id      = aws_subnet.PvtSN3.id
  route_table_id = aws_route_table.RTPvtSN3.id
}

resource "aws_network_acl" "NetworkAclPublic" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${local.stackName}-NetworkAclPublic"
  }
}

resource "aws_network_acl" "NetworkAclPrivate" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${local.stackName}-NetworkAclPrivate"
  }
}

resource "aws_network_acl_association" "SubnetNetworkAclAssociationPubSN1" {
  network_acl_id = aws_network_acl.NetworkAclPublic.id
  subnet_id      = aws_subnet.PubSN1.id
}

resource "aws_network_acl_association" "SubnetNetworkAclAssociationPubSN2" {
  network_acl_id = aws_network_acl.NetworkAclPublic.id
  subnet_id      = aws_subnet.PubSN2.id
}

resource "aws_network_acl_association" "SubnetNetworkAclAssociationPubSN3" {
  network_acl_id = aws_network_acl.NetworkAclPublic.id
  subnet_id      = aws_subnet.PubSN3.id
}

resource "aws_network_acl_association" "SubnetNetworkAclAssociationPvtSN1" {
  network_acl_id = aws_network_acl.NetworkAclPrivate.id
  subnet_id      = aws_subnet.PvtSN1.id
}

resource "aws_network_acl_association" "SubnetNetworkAclAssociationPvtSN2" {
  network_acl_id = aws_network_acl.NetworkAclPrivate.id
  subnet_id      = aws_subnet.PvtSN2.id
}

resource "aws_network_acl_association" "SubnetNetworkAclAssociationPvtSN3" {
  network_acl_id = aws_network_acl.NetworkAclPrivate.id
  subnet_id      = aws_subnet.PvtSN3.id
}

resource "aws_network_acl_rule" "NACLPubAllowAllIPv4In" {
  network_acl_id = aws_network_acl.NetworkAclPublic.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  from_port      = 0
  to_port        = 0
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "NACLPvtAllowAllIPv4In" {
  network_acl_id = aws_network_acl.NetworkAclPrivate.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  from_port      = 0
  to_port        = 0
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "NACLPubAllowAllIPv4Out" {
  network_acl_id = aws_network_acl.NetworkAclPublic.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  from_port      = 0
  to_port        = 0
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "NACLPvtAllowAllIPv4Out" {
  network_acl_id = aws_network_acl.NetworkAclPrivate.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  from_port      = 0
  to_port        = 0
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}
