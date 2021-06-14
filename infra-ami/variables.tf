variable "region" {
  description = "AWS region to deploy the sandbox starter ami"
  default     = "us-west-2"
}

variable "keypair" {
  description = "EC2 keypair that has been created in the var.region"
  default     = "your_key_pair"
}
