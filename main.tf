# bloco inicial padrão

terraform {
  required_version = "1.7.5"
  backend "local" {
    path = "terraform.tfsate"
  }
}

