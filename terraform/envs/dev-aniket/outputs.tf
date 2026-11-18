output "subnet_id" { value = data.aws_subnets.public.ids[0] }
output "staging_sg" { value = aws_security_group.staging.id }
output "pentest_sg" { value = aws_security_group.pentest.id }
output "cluster" { value = aws_ecs_cluster.s0.name }
output "registry" { value = split("/", aws_ecr_repository.demo_api.repository_url)[0] }
