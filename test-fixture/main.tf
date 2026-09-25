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
  default     = 2
}

module "pets" {
  source    = "./modules/pets"
  pet_count = var.pet_count
}

output "pet_names" {
  description = "The generated pet names."
  value       = module.pets.names
}
