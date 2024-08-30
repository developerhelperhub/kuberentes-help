#This script is where we define the common module needed for the parent and child modules.
terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
  }
}

#This resource is designed to generate a 16-character password across the system to enhance security. It can be used to create passwords for users, ensuring that each password includes special characters, uppercase and lowercase letters, and default numbers. You can also specify which special characters should be included in the password.
resource "random_password" "random_password_16" {
  length           = 16
  special          = true
  upper            = true
  lower            = true
  override_special = "#$%&" # Only these special characters are allowed
}
