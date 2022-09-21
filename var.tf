variable "AWS_REGION" {
    type = string
    default = "eu-west-1"
}

variable "AWS_SUBNET" {
  type = map
  default = {
   "eu-west-1a" = "10.5.1.0/24"
   "eu-west-1b" = "10.5.2.0/24"

  }

}