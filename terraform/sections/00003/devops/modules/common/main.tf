terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_password" "random_password_16" {
  length  = 16
  special = true
  upper   = true
  lower   = true
}