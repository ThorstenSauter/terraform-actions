terraform {
  required_version = ">= 1.10.0"
}

resource "terraform_data" "self_test" {
  input = "self-test"
}
