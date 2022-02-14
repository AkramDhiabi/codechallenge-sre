# api load balancer
resource "aws_lb" "graphql_api" {
  name               = "${local.prefix}-main"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  security_groups = [aws_security_group.lb.id]

  tags = local.common_tags
}

# load balancer SG
resource "aws_security_group" "lb" {
  description = "SG Allow access to Application Load Balancer"
  name        = "${local.prefix}-lb"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Create blue target group for graphql
resource "aws_lb_target_group" "blue_graphql" {
  name        = "${local.prefix}-bgraph"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 8080

  health_check {
    path = "/ping"
    #Response codes to use when checking for a healthy responses from a target
    matcher = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

# api green target group for blue/green deployment
resource "aws_lb_target_group" "green_graphql" {
  name        = "${local.prefix}-ggraph"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  port        = 8080

  health_check {
    path    = "/ping"
    matcher = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

# listener for graphql api
resource "aws_lb_listener" "graphql_http" {
  load_balancer_arn = aws_lb.graphql_api.arn
  port              = 80
  protocol          = "HTTP"

  # Get redirected to the https url
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Add a https listener to graphql alb and specify the certificate arn
resource "aws_lb_listener" "graphql_api_https" {
  load_balancer_arn = aws_lb.graphql_api.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = data.aws_acm_certificate.superb_issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_graphql.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}