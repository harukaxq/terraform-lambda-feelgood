resource "sentry_project" "this" {
  organization = var.sentry_org_name

  team = var.sentry_org_name
  name = var.name
  slug = var.name

  platform    = "node-awslambda"
  resolve_age = 720
}
resource "sentry_key" "this" {
  organization = var.sentry_org_name

  project = sentry_project.this.id
  name    = "default-key"
}
