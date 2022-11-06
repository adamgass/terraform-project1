data "terraform_remote_state" "vpc" {
    backend = "s3"
    config = {
        bucket = "tf-s3-backend-092385772206"
        key = "vpc-tf.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "s3" {
    backend = "s3"
    config = {
        bucket = "tf-s3-backend-092385772206"
        key = "s3-tf.tfstate"
        region = "us-east-1"
    }
}