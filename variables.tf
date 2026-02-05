
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_az" {
  type    = string
  default = "us-east-1a"
}


variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "pub_sub_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "pvt_sub_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "pvt_instance_type" {
  description = "pvt instance type"
  type        = string
  default     = "t3.medium"
}

variable "pub_instance_type" {
  description = "pub instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami" {
  type    = string
  default = "ami-0b6c6ebed2801a5cb"
}