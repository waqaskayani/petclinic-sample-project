resource "aws_lb" "app_alb" {
    name               = "alb-app-${var.environment}"
    internal           = false
    load_balancer_type = "application"
    subnets            = module.vpc.public_subnets
    security_groups    = [ aws_security_group.alb_sg.id ]
    enable_deletion_protection = var.alb_delete_protection

    # access_logs {
    #     bucket  = aws_s3_bucket.lb_logs.id
    #     prefix  = "alb-asg-${var.environment}-logs"
    #     enabled = true
    # }

    tags = merge(
            { 
                "Name" = "alb-app-${var.environment}"
            },
            var.common_tags
    )
}

resource "aws_lb_target_group" "application_tg" {
    name                    = "tg-app-${var.environment}"
    port                    = 9966
    protocol                = "HTTP"
    target_type             = "instance"
    vpc_id                  = module.vpc.vpc_id
    deregistration_delay    = 30

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 2
      interval            = 5
      path                = "/petclinic/"
    }
}

resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.app_alb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type = "redirect"

        redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
        }
    }

    tags = merge(
        { 
            "Name" = "http-listener-${var.environment}"
        },
        var.common_tags
    )
}

resource "aws_lb_listener" "https_listener" {
    load_balancer_arn = aws_lb.app_alb.arn
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = aws_acm_certificate.app_cert.arn

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.application_tg.arn
    }

    tags = merge(
        { 
            "Name" = "https-listener-${var.environment}"
        },
        var.common_tags
    )
}
