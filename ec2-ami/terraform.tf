terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "tf-s3-backend-092385772206"
    key            = "ec2-tf.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-table"
  }
}