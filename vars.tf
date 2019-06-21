variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "PATH_TO_PUBLIC_KEY" {}
variable "AWS_REGION" {default = "us-west-2"}

variable "AMIS" {
    type = "map"
    default = {
    us-west-2 = "ami-005bdb005fb00e791"
    }
}