# docker-buildスクリプトを作成
resource "local_file" "ignoreifle" {
  filename = "./script/.gitignore"
  content  = "*"
}
resource "local_file" "docker-build" {
  count    = var.type == "docker" ? 1 : 0
  filename = "./script/${var.name}/docker-build.sh"
  content  = <<EOF
#!/bin/bash
cd ${abspath(var.build_path)}
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
docker build -t ${var.name} \
    --build-arg SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
    --build-arg SENTRY_URL=${var.sentry_base_url} \
    --build-arg SENTRY_PROJECT_NAME=${var.name} \
    --build-arg SENTRY_RELEASE=${var.name}@${data.archive_file.zip.output_sha} \
    --build-arg SENTRY_ORG_NAME=${var.sentry_org_name} \
    .
EOF
}
resource "local_file" "docker-deploy" {
  count    = var.type == "docker" ? 1 : 0
  filename = "./script/${var.name}/deploy-docker.sh"
  content  = <<EOF
#!/bin/bash
cd `dirname $0`
bash docker-build.sh
cd ${abspath(var.build_path)}
docker push ${module.build[0].image_uri}
aws lambda update-function-code --function-name ${module.function.lambda_function_name} --image-uri ${module.build[0].image_uri}
awa lambda wait function-updated --function-name ${module.function.lambda_function_name}
echo "Deployed ${module.build[0].image_uri}"
EOF
}
# local-buildスクリプトを作成
resource "local_file" "local-build" {
  filename = "./script/${var.name}/build-local.sh"
  content  = <<EOF
#!/bin/bash
cd ${abspath(var.build_path)}
    SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
    SENTRY_URL=${var.sentry_base_url} \
    SENTRY_PROJECT_NAME=${var.name} \
    SENTRY_RELEASE=${var.name}@${data.archive_file.zip.output_sha} \
    SENTRY_ORG_NAME="${var.sentry_org_name}" \
yarn build
EOF
}
# invoke-localスクリプトを作成
resource "local_file" "invoke-local" {
  filename = "./script/${var.name}/invoke-local.sh"
  content  = <<EOF
#!/bin/bash
cd ${abspath(var.build_path)}
    SENTRY_AUTH_TOKEN=${var.sentry_auth_token} \
    SENTRY_URL=${var.sentry_base_url} \
    SENTRY_PROJECT_NAME=${var.name} \
    SENTRY_RELEASE=${var.name}@${data.archive_file.zip.output_sha} \
    SENTRY_ORG_NAME="${var.sentry_org_name}" \
yarn build
node .build/index.js
  EOF
}
resource "local_file" "payload_json" {
  filename = "./script/${var.name}/payload.json"
  content  = <<EOF
{
  "body": "Hello World"
}
  EOF
}

resource "local_file" "invoke-aws" {
  count    = var.create_script ? 1 : 0
  filename = "./script/${var.name}/invoke-aws.sh"
  content  = <<EOF
#!/bin/bash
cd `dirname $0`
aws lambda invoke --function-name ${var.name} \
  --payload file://payload.json result \
  --cli-binary-format raw-in-base64-out \
  --log-type Tail \
  --query 'LogResult' | tr -d '"' | base64 -D &&\
   cat result
  EOF
}

resource "local_file" "logs-aws" {
  count    = var.create_script ? 1 : 0
  filename = "./script/${var.name}/log-aws.sh"
  content  = <<EOF
#!/bin/bash
awslogs get "${module.function.lambda_cloudwatch_log_group_name}" -w
  EOF
}
