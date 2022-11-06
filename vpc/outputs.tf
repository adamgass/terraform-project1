output "vpc_id" {
  value = aws_vpc.VPC.id
}

output "PubSN1_id" {
  value = aws_subnet.PubSN1.id
}

output "PubSN2_id" {
  value = aws_subnet.PubSN2.id
}

output "PubSN3_id" {
  value = aws_subnet.PubSN3.id
}

output "PvtSN1_id" {
  value = aws_subnet.PvtSN1.id
}

output "PvtSN2_id" {
  value = aws_subnet.PvtSN2.id
}

output "PvtSN3_id" {
  value = aws_subnet.PvtSN3.id
}

output "web_alb_sg"{
  value = aws_security_group.web-alb-sg.id
}

output "web-server-sg"{
  value = aws_security_group.web-server-sg.id
}

output "bastion-host-sg"{
  value = aws_security_group.baston-host-sg.id
}

output "myKey" {
  value = aws_key_pair.myKey.id
}