data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "<s3 bucket name>"
        key = "vpc-tf.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "s3" {
    backend = "s3"
    config = {
        bucket = "<s3 bucket name>"
        key = "s3-tf.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "ec2" {
    backend = "s3"
    config = {
        bucket = "<s3 bucket name>"
        key = "ec2-tf.tfstate"
        region = "<aws region>"
    }
}
