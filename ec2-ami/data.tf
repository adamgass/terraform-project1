data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "<s3 bucket name>"
    key    = "vpc-tf.tfstate"
    region = "<aws region>"
  }
}

data "terraform_remote_state" "elb" {
  backend = "s3"
  config = {
    bucket = "<s3 bucket name>"
    key    = "elb-tf.tfstate"
    region = "<aws region>"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "<s3 bucket name>"
    key    = "s3-tf.tfstate"
    region = "<aws region>"
  }
}
