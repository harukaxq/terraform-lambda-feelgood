terraform {
  required_version = "~> 1.3.9"
  required_providers {
    sentry = {
      source = "jianyuan/sentry"
    }
    aws = {
      source  = "hashicorp/aws"
    }
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}
data "aws_region" "current" {}
data "aws_caller_identity" "this" {}
data "aws_ecr_authorization_token" "token" {}
provider "docker" {
  registry_auth {
    address  = format("%v.dkr.ecr.%v.amazonaws.com", data.aws_caller_identity.this.account_id, data.aws_region.current.name)
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
locals {
  release = "${var.name}@${data.archive_file.zip.output_sha}"
}
module "function" {
  source  = "terraform-aws-modules/lambda/aws"
  runtime = var.runtime
  handler = var.handler

  function_name = var.name

  create_package  = var.type == "docker" ? false : true
  source_path = var.type == "docker" ? null : {
    path = var.build_path,
    commands = [
      "yarn install --frozen-lockfile",
      <<EOF
        SENTRY_URL=${var.sentry_base_url} \
        SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
        SENTRY_ORG_NAME=${var.sentry_org_name} \
        SENTRY_RELEASE=${local.release} \
        SENTRY_PROJECT_NAME=${sentry_project.this.name} \
        yarn build
      EOF
      ,
      "cd .build",
      ":zip . ",
    ]
  }

  create_lambda_function_url = var.create_lambda_function_url
  timeout                    = var.timeout
  memory_size                = var.memotry_size
  ephemeral_storage_size     = var.ephemeral_storage_size
  image_uri                  = var.type == "docker" ? module.build[0].image_uri : null
  package_type               = var.type == "docker" ? "Image" : "Zip"
  attach_policy_statements   = var.policy_statements != {} ? true : false
  environment_variables = merge({
    SENTRY_DSN     = sentry_key.this.dsn_public
    SENTRY_RELEASE = local.release
  }, var.environment_variables)

  policy_statements = var.policy_statements
}

module "build" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"
  count  = var.type == "docker" ? 1 : 0

  platform = "linux/amd64"
  create_ecr_repo = true
  ecr_repo        = var.name
  ecr_repo_lifecycle_policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep only the last 2 images",
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 2
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })

  build_args = {
    "SENTRY_URL"          = var.sentry_base_url
    "SENTRY_AUTH_TOKEN"   = var.sentry_auth_token
    "SENTRY_PROJECT_NAME" = sentry_project.this.name
    "SENTRY_RELEASE"      = local.release
    "SENTRY_ORG_NAME"     = var.sentry_org_name
  }
  image_tag   = data.archive_file.zip.output_sha
  source_path = var.build_path
}
data "archive_file" "zip" {
  type        = "zip"
  source_dir  = var.build_path
  output_path = "${path.module}/.build/${var.name}.zip"
  excludes = [
    "node_modules",
    ".build",
    "*.log"
  ]
}