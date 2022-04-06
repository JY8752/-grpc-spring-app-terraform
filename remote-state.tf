terraform {
  backend "remote" {
    organization = "myself_jy8752"
    workspaces {
      name = "grpc-spring-app-terraform"
    }
  }
}
