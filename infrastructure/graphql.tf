resource "aws_security_group" "graphql" {
  description = "Access for the graphql service"
  name        = "${local.prefix}-graphql-service"
  vpc_id      = aws_vpc.main.id

  egress {
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
      aws_security_group.lb.id
    ]
  }

  tags = local.common_tags
}

resource "aws_ecs_task_definition" "graphql" {
  family                   = "${local.prefix}-graphql"
  container_definitions    = data.template_file.container_def["graphql"].rendered
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
resource "aws_ecs_service" "graphql" {
  name            = "graphql"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.graphql.family
  desired_count   = 1
  launch_type     = "FARGATE"

  # put it in a private subnet 
  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.graphql.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue_graphql.arn
    container_name   = "graphql"
    container_port   = 8080
  }

  # Should wait for the alb listener in order to create the service
  depends_on = [aws_lb_listener.graphql_http]
}

