resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "myKey" {
  key_name   = "myKey" # Create a "myKey" to AWS
  public_key = tls_private_key.private-key.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer
    command = "echo '${tls_private_key.private-key.private_key_pem}' > ./myKey.pem"
  }
}