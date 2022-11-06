data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "<s3 bucket name>"
    key    = "vpc-tf.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "elb" {
  backend = "s3"
  config = {
    bucket = "<s3 bucket name>"
    key    = "elb-tf.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "<s3 bucket name>"
    key    = "s3-tf.tfstate"
    region = "us-east-1"
  }
}
