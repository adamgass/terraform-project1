locals {
  PrivateSubnet1  = data.terraform_remote_state.vpc.outputs.PvtSN1_id
  PrivateSubnet2  = data.terraform_remote_state.vpc.outputs.PvtSN2_id
  PrivateSubnet3  = data.terraform_remote_state.vpc.outputs.PvtSN3_id
  PublicSubnet1   = data.terraform_remote_state.vpc.outputs.PubSN1_id
  PublicSubnet2   = data.terraform_remote_state.vpc.outputs.PubSN2_id
  PublicSubnet3   = data.terraform_remote_state.vpc.outputs.PubSN3_id
  web-server-sg   = data.terraform_remote_state.vpc.outputs.web-server-sg
  bastion-host-sg = data.terraform_remote_state.vpc.outputs.bastion-host-sg
  myKey           = data.terraform_remote_state.vpc.outputs.myKey
  #web_server_lb   = data.terraform_remote_state.elb.outputs.web_server_lb
  #web_tg          = data.terraform_remote_state.elb.outputs.web_tg
}

resource "aws_iam_role" "ec2_allow_s3" {
  name = "ec2_allow_s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_allow_s3_attachment" {
  role       = aws_iam_role.ec2_allow_s3.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_allow_s3.name
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t3.micro"
  subnet_id       = local.PublicSubnet1
  key_name        = local.myKey
  security_groups = [local.bastion-host-sg]
  user_data       = <<-EOF
  #!/bin/bash
  curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.7/2022-06-29/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
  EOF

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "web-server" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t3.micro"
  subnet_id       = local.PrivateSubnet1
  key_name        = local.myKey
  security_groups = [local.web-server-sg]
  root_block_device {
    volume_size = 20
  }
  user_data = <<-EOF
  #!/bin/bash
  sudo yum install httpd -y
  sudo systemctl start httpd
  sudo touch /var/www/html/index.html
  sudo chown -R $USER:$USER /var/www
  sudo echo Hello Doug! > /var/www/html/index.html

  EOF
  tags = {
    Name = "web-server"
  }
}

resource "aws_ami_from_instance" "bastion-ami" {
  name               = "bastion-ami"
  source_instance_id = aws_instance.bastion.id
}

resource "aws_ami_from_instance" "web-ami" {
  name               = "web-ami"
  source_instance_id = aws_instance.web-server.id
}

resource "aws_launch_template" "bastion-template" {
  name          = "bastion-template"
  image_id      = aws_ami_from_instance.bastion-ami.id
  instance_type = "t2.micro"
  key_name      = local.myKey
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_profile.name
  }
  #vpc_security_group_ids = [local.bastion-host-sg]
  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = [local.bastion-host-sg]
  }

}

data "template_file" "start_httpd" {
  template = <<EOF
    #!/bin/bash
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo touch /var/www/html/index.html
    sudo chown -R $USER:$USER /var/www
    sudo echo Hello Doug! > /var/www/html/index.html
  EOF
}

resource "aws_launch_template" "web-template" {
  name          = "web-template"
  image_id      = aws_ami_from_instance.web-ami.id
  instance_type = "t2.micro"
  key_name      = local.myKey
  user_data = "${base64encode(data.template_file.start_httpd.template)}"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_profile.name
  }
  vpc_security_group_ids = [local.web-server-sg]
}