# AWS CodeBuild

resource "aws_codebuild_project" "build_java_project" {
    name          = "codebuild-app-${var.environment}-project"
    description   = "CodeBuild project for Java test application."
    build_timeout = "5"
    service_role  = aws_iam_role.codebuild_role.arn

    source {
        type            = "CODEPIPELINE"
        buildspec       = "buildspec.yml" # Replace with your buildspec file path
        git_clone_depth = 1
    }

    artifacts {
        type = "CODEPIPELINE"
    }

    vpc_config {
        security_group_ids = [ aws_security_group.codebuild_sg.id ]
        subnets = module.vpc.private_subnets
        vpc_id = module.vpc.vpc_id
    }

    logs_config {
        cloudwatch_logs {
            group_name  = "codebuild-log-app-${var.environment}-group"
        }
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/standard:5.0"
        type                        = "LINUX_CONTAINER"
        privileged_mode             = false
    }

    cache {
        type     = "S3"
        location = aws_s3_bucket.artifact_store.bucket
    }

    tags = merge(
            { 
                "Name" = "codebuild-app-${var.environment}-project"
            },
            var.common_tags
    )
}
