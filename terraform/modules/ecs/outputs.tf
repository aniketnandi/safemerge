output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "subnet_ids" {
  value = data.aws_subnets.public.ids
}

output "staging_sg_id" {
  value = aws_security_group.staging.id
}

output "pentest_sg_id" {
  value = aws_security_group.pentest.id
}

output "staging_task_definition_arn" {
  value = aws_ecs_task_definition.staging.arn
}

output "pentest_task_definition_arn" {
  value = length(aws_ecs_task_definition.pentest) > 0 ? aws_ecs_task_definition.pentest[0].arn : ""
}
