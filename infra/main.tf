provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      "owner"       = "terraform"
      "application" = "blue-green-demo"
    }
  }
}
