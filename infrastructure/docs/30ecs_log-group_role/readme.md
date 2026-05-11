# IAM Role vs IAM Permission vs Security Group
## IAM Role
**Was**: Eine Identität, die AWS-Services annehmen können **Zweck**: Definiert **WER** etwas tun darf **Beispiel**: `ecsTaskExecutionRole` - ECS Tasks können diese Rolle annehmen``` hcl
```resource "aws_iam_role" "ecs_task_execution_role" {
assume_role_policy = {
Principal: { Service: "ecs-tasks.amazonaws.com" }
}
}
```

## IAM Permission (Policy)
Was: Berechtigungen, die einer Role zugewiesen werden Zweck: Definiert WAS die Role tun darf (AWS API Calls) Beispiel: ECR Images pullen, Logs schreiben``` hcl
```
resource "aws_iam_role_policy" "ecr_vpc_endpoint_policy" {
  role = aws_iam_role.ecs_task_execution_role.id
  policy = {
    Action: ["ecr:GetDownloadUrlForLayer"]  # WAS darf gemacht werden
  }
}
```

## Security Group
Was: Firewall-Regeln für Netzwerk-Traffic Zweck: Definiert WOHER/WOHIN Netzwerk-Verbindungen erlaubt sind Beispiel: Port 80 von überall, Port 443 nur von VPC``` hcl

```
resource "aws_security_group" "nginx_sg" {
ingress {
from_port = 80  # WELCHER Port
cidr_blocks = ["0.0.0.0/0"]  # VON WO
}
}


## Zusammenfassung:
IAM Role: Identität ("Ich bin der ECS Task")
IAM Permission: AWS API Rechte ("Ich darf ECR lesen")
Security Group: Netzwerk-Firewall ("Ich darf auf Port 443 zugreifen")


ECS Service
  ↓ verwendet
ECS Task
  ↓ nimmt an (assume)
IAM Role (ecsTaskExecutionRole)
  ↓ hat
Permissions (ECR lesen, Logs schreiben)