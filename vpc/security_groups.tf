resource "aws_security_group" "web-alb-sg" {
  name        = "web-alb-sg"
  description = "security group for public facing web server alb"
  vpc_id      = aws_vpc.VPC.id
  ingress {
    description = "allow port 80 traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound"
    from_port   = 0
    protocol    = -1
    to_port     = 0
  }
  tags = {
    Name = "web-alb-sg"
  }
}

resource "aws_security_group" "web-server-sg" {
  name        = "web-server-sg"
  description = "security group for backend web instances"
  vpc_id      = aws_vpc.VPC.id
  ingress {
    description     = "allow all from alb SG"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.web-alb-sg.id]
  }
  ingress {
    description     = "allow all from bastion SG"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = [aws_security_group.baston-host-sg.id]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound"
    from_port   = 0
    protocol    = -1
    to_port     = 0
  }
  tags = {
    Name = "web-server-sg"
  }
}

resource "aws_security_group" "baston-host-sg" {
  name        = "bastion-sg"
  description = "security group for bastion hosts"
  vpc_id      = aws_vpc.VPC.id
  ingress {
    description = "allow port 80 traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound"
    from_port   = 0
    protocol    = -1
    to_port     = 0
  }
  tags = {
    Name = "bastion-host-sg"
  }
}