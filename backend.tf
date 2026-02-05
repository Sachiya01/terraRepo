terraform {
  backend "s3" {
    bucket         = "sachithtfbucket"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
