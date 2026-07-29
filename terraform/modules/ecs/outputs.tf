output "cluster_name" { 
description = "The cluster name of the ecs" 
value = aws_ecs_cluster.main.name
}

output "service_name" { 
description = "The service name of the ecs" 
value = aws_ecs_service.main.name
}