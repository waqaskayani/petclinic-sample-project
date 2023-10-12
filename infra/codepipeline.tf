
# AWS CodePipeline

resource "aws_codestarconnections_connection" "app_codestar_connection" {
    name          = "app-codestar-${var.environment}"
    provider_type = "GitHub"
}

resource "aws_codepipeline" "app_pipeline" {
    name     = "codepipeline-app-${var.environment}"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
        location = aws_s3_bucket.artifact_store.bucket
        type     = "S3"
    }

    stage {
        name = "Source"
        action {
            name             = "Source"
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeStarSourceConnection"
            version          = "1"
            output_artifacts = ["source_output"]

            configuration = {
                ConnectionArn    = aws_codestarconnections_connection.app_codestar_connection.arn
                FullRepositoryId = var.repository_id
                BranchName       = var.repository_branch
            }
        }
    }

    stage {
        name = "Build"
        action {
            name             = "Build"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            input_artifacts  = ["source_output"]
            output_artifacts = ["build_output"]
            version          = "1"

            configuration = {
                ProjectName = aws_codebuild_project.build_java_project.name
            }
        }
    }

    stage {
        name = "Deploy"
        action {
            name            = "Deploy"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CodeDeploy"
            input_artifacts = ["build_output"]
            version         = "1"

            configuration = {
                ApplicationName  = aws_codedeploy_app.codedeploy_java_app.name
                DeploymentGroupName = aws_codedeploy_deployment_group.codedeploy_deployment_group.deployment_group_name
            }
        }
    }

    tags = merge(
            { 
                "Name" = "codepipeline-app-${var.environment}"
            },
            var.common_tags
    )
}
