# Assign the permissions in order to start tasks

resource "aws_iam_policy" "superb_execution_role_policy" {
  name        = "${local.prefix}-superb-exec-role-policy"
  path        = "/"
  description = "Allow retrieving images and adding to logs"
  policy      = file("./templates/task-exec-role.json")
}

resource "aws_iam_role" "superb_execution_role" {
  name               = "${local.prefix}-superb-exec-role"
  assume_role_policy = file("./templates/assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.superb_execution_role.name
  policy_arn = aws_iam_policy.superb_execution_role_policy.arn
}

# this IAM role "app_iam_role" is needed to give permission to our taks that needs at runtime
# those permissions that docker container needs when is starting

resource "aws_iam_role" "app_iam_role" {
  name               = "${local.prefix}-superb-task"
  assume_role_policy = file("./templates/assume-role-policy.json")

  tags = local.common_tags
}