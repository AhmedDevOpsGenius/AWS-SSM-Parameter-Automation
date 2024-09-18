output "ssm_param_names" {
  value = [for param in aws_ssm_parameter.ssm_params : param.name]
}
