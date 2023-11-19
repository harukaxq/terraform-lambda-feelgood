resource "sentry_project" "this" {
  organization = var.sentry_org_name

# var.sentry_teamsが[]なら、sentry_org_nameのチームに所属する
  teams = var.sentry_teams == [] ? [var.sentry_org_name] : var.sentry_teams
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
