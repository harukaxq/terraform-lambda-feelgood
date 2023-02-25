variable "name" {
}
variable "build_path" {
}
variable "environment_variables" {
  default = {}
}
variable "runtime" {
  default = "nodejs18.x"
}
variable "type" {
  default = "docker"
}
variable "handler" {
  default = "index.handler"
}
variable "timeout" {
  default = 900
}
variable "memotry_size" {
  default = 10240
}
variable "ephemeral_storage_size" {
  default = 10240
}
variable "create_sentry_project" {
  default = true
}
variable "sentry_auth_token" {
}
variable "sentry_org_name" {
  default = "cibo"
}
variable "sentry_base_url" {
  default = "https://sentry.io"
}
variable "policy_statements" {
  default = {}
}
variable "create_script" {
  default = true
}
variable "create_lambda_function_url" {
  default = false
}
  