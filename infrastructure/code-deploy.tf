# codedeploy application for api
resource "aws_codedeploy_app" "graphql" {
  name             = "${local.prefix}-graphql-blue-green"
  compute_platform = "ECS"
}

data "aws_iam_role" "codedeploy" {
  name = "CodeDeployECSRole"
}

resource "aws_codedeploy_deployment_group" "graphql_blue_green" {
  app_name               = aws_codedeploy_app.graphql.name
  deployment_group_name  = "${local.prefix}-dg-graphql"
  service_role_arn       = data.aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  # You can configure options for a blue/green deployment.
  # https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_BlueGreenDeploymentConfiguration.html
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  # For ECS deployment, the deployment type must be BLUE_GREEN, and deployment option must be WITH_TRAFFIC_CONTROL.
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  # Configuration block(s) of the ECS services for a deployment group.
  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.graphql.name
  }

  # You can configure the Load Balancer to use in a deployment.
  load_balancer_info {
    # Information about two target groups and how traffic routes during an Amazon ECS deployment.
    # An optional test traffic route can be specified.
    # https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_TargetGroupPairInfo.html
    target_group_pair_info {
      # The path used by a load balancer to route production traffic when an Amazon ECS deployment is complete.
      prod_traffic_route {
        listener_arns = [aws_lb_listener.graphql_api_https.arn]
      }

      # One pair of target groups. One is associated with the original task set.
      # The second target is associated with the task set that serves traffic after the deployment completes.
      target_group {
        name = aws_lb_target_group.blue_graphql.name
      }

      target_group {
        name = aws_lb_target_group.green_graphql.name
      }
    }
  }
}

resource "null_resource" "redeploy_graphql" {
  triggers = {
    task_definition_arn = "${aws_ecs_task_definition.graphql.arn}"
  }

  provisioner "local-exec" {
    command = "./bin/redeploy ${aws_codedeploy_app.graphql.name} ${aws_codedeploy_deployment_group.graphql_blue_green.deployment_group_name} graphql 3000 ${aws_ecs_task_definition.graphql.arn}"
  }
}