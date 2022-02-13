# ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

# common Cloudwatch log group for backend services
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name              = "${local.prefix}-superb-backend"
  retention_in_days = 30

  tags = local.common_tags
}

locals {
  backend_services = {
    "auth" = {
      template = "auth.def.json.tpl"
    }
    "booking" = {
      template = "booking.def.json.tpl"
    }
    "graphql" = {
      template = "graphql.def.json.tpl"
    }
  }
}

# Get DB endpoint
data "aws_ssm_parameter" "superb_endpoint" {
  name = "/backend/mongo/dbendpoint"
}

data "template_file" "container_def" {
  for_each = local.backend_services
  template = file("${path.module}/templates/${each.value.template}")
  vars = {
    app_name         = "${each.key}"
    log_group_name   = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region = local.region_id
    auth_image       = var.auth_image
    booking_image    = var.booking_image
    mongodb_url      = "${data.aws_ssm_parameter.superb_endpoint.arn}"
    graphql_image    = var.graphql_image
    booking_uri      = "booking.local"
    auth_uri         = "auth.local"
  }
}