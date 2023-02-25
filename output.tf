output "lambda_function_arn" {
  value = module.function.lambda_function_arn
}
output "lambda_function_name" {
  value = module.function.lambda_function_name
}
output "lambda_function_version" {
  value = module.function.lambda_function_version
}
output "lambda_function_url" {
  value = try(module.function.lambda_function_url,"")
}
output "lambda_cloudwatch_log_group_arn" {
  value = module.function.lambda_cloudwatch_log_group_arn
}
output "lambda_cloudwatch_log_group_name" {
  value = module.function.lambda_cloudwatch_log_group_name
}
output "sentry_project_id" {
  value = sentry_project.this.id
}