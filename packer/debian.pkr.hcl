packer {
  required_plugins {
    amazon = {
      version = "1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "bg-demo-ubuntu-minimal-22.04-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-amd64-minimal-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  ssh_username = "ubuntu"

  tags = {
    "owner"       = "packer"
    "application" = "blue-green-demo"
    "Name"        = "blue-green-demo"
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Update OS",
      "sudo apt-get update",
      "sudo apt-get -qy upgrade",
      "sudo apt-get -qy install unzip ca-certificates curl gnupg lsb-release",
      "sudo apt-get autoremove",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo Install docker",
      "sudo mkdir -m 0755 -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get -qy install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo Install Amazon ECR credential helper",
      "curl https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.6.0/linux-amd64/docker-credential-ecr-login -o docker-credential-ecr-login",
      "mv docker-credential-ecr-login /user/local/bin"
    ]
  }

  provisioner "file" {
    source      = "docker-config.json"
    destination = "~/.docker/config.json"
  }

  provisioner "shell" {
    inline = [
      "echo Install AWS CLI",
      "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "unzip -qq awscliv2.zip",
      "sudo ./aws/install"
    ]
  }
}