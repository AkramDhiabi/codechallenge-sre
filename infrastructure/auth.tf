resource "aws_security_group" "auth" {
  description = "Access for the auth service"
  name        = "${local.prefix}-auth-service"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      aws_security_group.graphql.id
    ]
  }

  tags = local.common_tags
}

resource "aws_ecs_task_definition" "auth" {
  family                   = "${local.prefix}-auth"
  container_definitions    = data.template_file.container_def["auth"].rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  # the permission needed by our task in order to start/run docker containers
  execution_role_arn = aws_iam_role.superb_execution_role.arn
  # the permission needed by our task at the run time
  task_role_arn = aws_iam_role.app_iam_role.arn

  tags = local.common_tags
}

# project-activity-cron ECS service
resource "aws_ecs_service" "auth" {
  name            = "auth"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.auth.family
  desired_count   = 1
  launch_type     = "FARGATE"

  # put it in a private subnet 
  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.auth.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.auth.arn
    container_name = "auth"
  }
}

resource "aws_service_discovery_service" "auth" {
  name = "auth"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.superb-backend.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
