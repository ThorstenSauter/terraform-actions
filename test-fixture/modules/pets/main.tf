terraform {
  required_version = ">= 1.5.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "pet_count" {
  description = "Number of random pets to create."
  type        = number
}

resource "random_pet" "this" {
  count  = var.pet_count
  length = 3
  keepers = {
    index = count.index
  }
}

output "names" {
  description = "The generated pet names."
  value       = random_pet.this[*].id
}
