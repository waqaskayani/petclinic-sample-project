resource "aws_launch_template" "app_lt" {
    name          = "app-lt-${var.environment}"
    image_id      = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name      = var.pem_key_name
    block_device_mappings {
      device_name = "/dev/sda1"

      ebs {
          encrypted           = true
          volume_size         = 8
          volume_type         = "gp2"
          delete_on_termination = true
      }
    }

    iam_instance_profile {
        name = aws_iam_instance_profile.ec2_instance_profile.name
    }

    vpc_security_group_ids = [ aws_security_group.ec2_sg.id, aws_security_group.instance_connect_sg.id ]
    user_data = base64encode( <<EOF
#!/bin/bash
apt-get update -y
apt-get install unzip -y

# Installing AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Installing Java and Tomcaat
wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
add-apt-repository 'deb https://apt.corretto.aws stable main'
apt-get install java-1.8.0-amazon-corretto-jdk maven -y

# Installing CodeDeploy agent
apt-get install ruby-full wget -y
wget https://aws-codedeploy-${data.aws_region.current.name}.s3.${data.aws_region.current.name}.amazonaws.com/latest/install
chmod +x ./install
./install auto > /tmp/logfile

apt-get install nginx -y

systemctl start codedeploy-agent.service
systemctl enable codedeploy-agent.service
systemctl status codedeploy-agent.service
systemctl start nginx.service
systemctl enable nginx.service
systemctl status nginx.service
EOF
)

    tags = merge(
        { 
            "Name" = "app-lt-${var.environment}"
        },
        var.common_tags
    )

    tag_specifications {
        resource_type = "instance"

        tags = merge(
        { 
            "Name" = "app-ec2-${var.environment}"
        },
        var.common_tags
    )
    }
}

resource "aws_autoscaling_group" "app_asg" {
    name = "app-asg-${var.environment}"
    desired_capacity   = 1
    max_size           = 1
    min_size           = 1
    health_check_grace_period = 120
    health_check_type         = "ELB"

    target_group_arns = [ aws_lb_target_group.application_tg.arn ]

    launch_template {
      id      = aws_launch_template.app_lt.id
      version = "$Latest"
    }

    vpc_zone_identifier = module.vpc.private_subnets
}

resource "aws_ec2_instance_connect_endpoint" "ec2_instance_connect" {
    subnet_id          = module.vpc.private_subnets[0]
    security_group_ids = [ aws_security_group.instance_connect_sg.id ]
    preserve_client_ip = false

    tags = { 
        "Name" = "ec2-ic-endpoint-app-${var.environment}"    
    }
}
