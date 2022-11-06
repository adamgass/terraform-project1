output "web_server_lb" {
    value = aws_lb.web-server-lb.id
}

output "web_tg" {
    value = aws_lb_target_group.web.arn
}