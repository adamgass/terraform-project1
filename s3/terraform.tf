terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "<s3 bucket name>"
    key            = "s3-tf.tfstate"
    region         = "<aws region>"
    dynamodb_table = "<dynamodb table name>"
  }
}