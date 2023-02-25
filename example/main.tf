terraform {
  required_version = "~> 1.3.9"
  required_providers {
    sentry = {
      source = "jianyuan/sentry"
    }
    aws = {
      source = "hashicorp/aws"
    }
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
provider "aws" {
  profile = "cibo"
}
provider "sentry" {
  base_url = "${var.sentry_base_url}/api"
  token    = var.sentry_auth_token
}
variable "sentry_base_url" {

}
variable "sentry_auth_token" {

}
module "function" {
  source     = "../"
  name       = "app"
  build_path = "./function/"
  sentry_base_url = var.sentry_base_url
  sentry_auth_token = var.sentry_auth_token
  build_args = {
    MODE = "production"
  }
}
