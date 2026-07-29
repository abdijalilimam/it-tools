#iam role. this is like a job title without responsibilities 
resource "aws_iam_role" "ecs_execution" {
  name = "${var.ecs_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

#execution role. this is the job describtion of the job title 
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#aws ecs cluster 
resource "aws_ecs_cluster" "main" {
  name = var.ecs_name
  
  tags = {
    Name = var.ecs_name
  }
}

#security group
resource "aws_security_group" "ecs" {
  name   = "${var.ecs_name}-ecs-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
security_groups = [var.alb_security_group_id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.ecs_name}-ecs-sg"
  }
}

#task definition
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.ecs_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  container_definitions = jsonencode([{
    name  = var.ecs_name
    image = var.container_image
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
  }])
}


#ecs service
resource "aws_ecs_service" "main" {
  name            = "${var.ecs_name}-service"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.ecs_name
    container_port   = 80
  }
}