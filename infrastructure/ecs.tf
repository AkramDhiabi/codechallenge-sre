# ECS cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-cluster"

  tags = local.common_tags
}

# common ECS service Security Group
resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS service"
  name        = "${local.prefix}-ecs-service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # the port the backend runs on as the entrypoint of our app
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]
  }

  tags = local.common_tags
}

locals {
  backend_services = {
    "auth" = {
      template = "auth.def.json.tpl"
    },
    "booking" = {
      template = "booking.def.json.tpl"
    },
    "graphql" = {
      template = "graphql.def.json.tpl"
    }
  }
}

data "template_file" "container_def" {
  for_each = local.backend_services
  template = file("${path.module}/templates/${each.value.template}")
  vars = {
    app_name         = "${each.key}"
    log_group_name   = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region = local.region_id
    auth_image       = var.ecr_auth_image
    booking_image    = var.ecr_auth_image
    mongodb_url      = "?"
  }
}