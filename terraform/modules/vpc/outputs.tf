#This file is needed for passing these ids to other modules so they are connected 
#The output for vpc 
output "vpc_id" {
  description = "The ID that will be given after vpc is created"
  value       = aws_vpc.main.id
}

#The output for public subnets i used [*] to refrence both of the subnets 
output "public_subnet_ids" {
  description = "the ids for both public subnets"
  value       = aws_subnet.public[*].id
}

#The output for private subnets i used [*] to refrence both of the subnets 
output "private_subnet_ids" {
  description = "the ids for both private subnets"
  value       = aws_subnet.private[*].id
}