resource "aws_ecs_cluster" "nginx_cluster" {
  name = "nginx-cluster"
}

resource "aws_ecs_service" "nginx_service" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.nginx_cluster.id
  task_definition = aws_ecs_task_definition.nginx_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_id_eur_cent_1]
    security_groups = [aws_security_group.nginx_sg.id]
    assign_public_ip = true
  }

  depends_on = [aws_ecs_task_definition.nginx_task]
}


resource "aws_ecs_task_definition" "nginx_task" {
  family                   = "nginx-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  runtime_platform {
    cpu_architecture = "X86_64"
  }
  container_definitions = <<DEFINITION
  [
    {
      "name": "nginx-container",
      "image": "230355213662.dkr.ecr.eu-central-1.amazonaws.com/pond-ecr-repo:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nginx",
          "awslogs-region": "eu-central-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/nginx"   # Dies sollte mit der Log-Gruppe in der Task-Definition übereinstimmen
  retention_in_days = 7              # Optional: Aufbewahrungszeit in Tagen
}

# Hier EU Central1 aus dem account der VPC eingeben
variable "subnet_id_eur_cent_1" {
  description = "The ID of the public subnet to use for the ECS service."
  type        = string
  default = "subnet-0433309f5b2a351b3"
}
