# AWS CodeDeploy
resource "aws_codedeploy_app" "codedeploy_java_app" {
    name = "codedeploy-app-${var.environment}"

    tags = merge(
            { 
                "Name" = "codedeploy-app-${var.environment}"
            },
            var.common_tags
    )
}

resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
    app_name               = aws_codedeploy_app.codedeploy_java_app.name
    deployment_group_name  = "codedeploy-${var.environment}-deployment-group"
    service_role_arn       = aws_iam_role.codedeploy_role.arn
    autoscaling_groups     = [ aws_autoscaling_group.app_asg.name ]

    auto_rollback_configuration {
        enabled = true
        events  = ["DEPLOYMENT_FAILURE"]
    }

    load_balancer_info {
        target_group_info {
            name = aws_lb_target_group.application_tg.name
        }
    }

    tags = merge(
            { 
                "Name" = "codedeploy-dep-group-${var.environment}"
            },
            var.common_tags
    )
}
