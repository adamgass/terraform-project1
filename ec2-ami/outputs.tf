output "bastion_template" {
    value = aws_launch_template.bastion-template.id
}

output "web_template" {
    value = aws_launch_template.web-template.id
}
output "web_template_version" {
    value = aws_launch_template.web-template.latest_version
}