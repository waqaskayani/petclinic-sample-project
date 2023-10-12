# IAM Role for EC2s
resource "aws_iam_role" "ec2_role" {
    name = "ec2-app-${var.environment}-role"

    assume_role_policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy" "ec2_ssm_policy" {
    name = "ec2-read-ssm-parameter-${var.environment}-policy"
    role = aws_iam_role.ec2_role.id
    policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": [
                "${aws_ssm_parameter.db_host.arn}",
                "${aws_ssm_parameter.db_password.arn}",
                "${aws_ssm_parameter.db_user.arn}",
                "${aws_ssm_parameter.db_name.arn}"
            ]
        }
    ]
}
EOT
}


resource "aws_iam_role_policy_attachment" "ec2_instance_connect_policy_attachment" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/EC2InstanceConnect"
}

resource "aws_iam_role_policy_attachment" "ec2_codedeploy_policy_attachment" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "ec2-app-${var.environment}-instance-profile"
    role = aws_iam_role.ec2_role.name
}


# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
    name = "codebuild-project-${var.environment}-role"

    assume_role_policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy" "codebuild_policy" {
    name = "codebuild-project-${var.environment}-policy"
    role = aws_iam_role.codebuild_role.id
    policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.artifact_store.id}",
                "arn:aws:s3:::${aws_s3_bucket.artifact_store.id}/*"
            ]
        },
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:codebuild-log-app-${var.environment}-group:log-stream:*",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:codebuild-log-app-${var.environment}-group"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath",
                "ssm:GetParameters"
            ],
            "Resource": [
                "${aws_ssm_parameter.db_host.arn}",
                "${aws_ssm_parameter.db_password.arn}",
                "${aws_ssm_parameter.db_user.arn}",
                "${aws_ssm_parameter.db_name.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:StartBuild",
                "codebuild:BatchGetBuilds"
            ],
            "Resource": "arn:aws:codebuild:::project/codebuild-app-${var.environment}-project"
        },
        {
            "Effect": "Allow", 
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs",
                "ec2:CreateNetworkInterfacePermission"
            ], 
            "Resource": "*"
        }
    ]
}
EOT
}


# IAM Role for CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
    name = "codedeploy-app-${var.environment}-role"

    assume_role_policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy" "codedeploy_policy" {
    name = "codedeploy-app-${var.environment}-policy"
    role = aws_iam_role.codedeploy_role.id
    policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Effect": "Allow",
            "Resource": "${aws_s3_bucket.artifact_store.arn}"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}


# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
    name = "codepipeline-app-${var.environment}-role"

    assume_role_policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy" "codepipeline_policy" {
    name = "codepipeline-app-${var.environment}-policy"
    role = aws_iam_role.codepipeline_role.id
    policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "${aws_s3_bucket.artifact_store.arn}",
                "${aws_s3_bucket.artifact_store.arn}/*"
            ]
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Effect": "Allow",
            "Resource": "${aws_codebuild_project.build_java_project.arn}"
        },
        {
            "Action": [
                "codedeploy:CreateDeployment",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:GetApplicationRevision",
                "codedeploy:RegisterApplicationRevision"
        ],
            "Effect": "Allow",
            "Resource": [
                "${aws_codedeploy_app.codedeploy_java_app.arn}",
                "${aws_codedeploy_deployment_group.codedeploy_deployment_group.arn}",
                "arn:aws:codedeploy:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:deploymentconfig:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codestar-connections:PassConnection",
                "codestar-connections:UseConnection"
            ],
            "Resource": "${aws_codestarconnections_connection.app_codestar_connection.arn}",
            "Condition": {"ForAllValues:StringEquals": {"codestar-connections:PassedToService": "codepipeline.amazonaws.com"}}
        }   
    ]
}
EOT
}
