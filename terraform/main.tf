provider "aws" {
  region = var.region
  default_tags {
    tags = {
      "owner"       = "terraform"
      "application" = "blue-green-demo"
    }
  }
}


data "aws_availability_zones" "azs" {
}
