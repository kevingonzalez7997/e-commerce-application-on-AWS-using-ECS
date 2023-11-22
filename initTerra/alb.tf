# Target Group
resource "aws_lb_target_group" "target_group" {
  name        = "D8target"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.app_vpc.id

  health_check {
    enabled = true
    path    = "/health"
  }

  depends_on = [aws_alb.ALB]
}

# Application Load Balancer
resource "aws_alb" "ALB" {
  name               = "D8ALB"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
  ]

  security_groups = [
    aws_security_group.http.id,
  ]

  depends_on = [aws_internet_gateway.igw]
}

# ALB Listener
resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Output
output "alb_url" {
  value = "http://${aws_alb.ALB.dns_name}"
}