variable "component_names" {
  type    = list(string)
  default = ["RDS", "FSx", "EC2", "ECR", "CloudMap"]
}

data "terraform_remote_state" "components" {
  backend = "local"

  config = {
    path = "../${var.component_name}/terraform.tfstate"
  }

  for_each = toset(var.component_names)
}

resource "aws_ecs_cluster" "microservices" {
  name = var.name_ecs_cluster

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_policy" "ecs_logs_policy" {
  name        = "ecsLogsPolicy"
  description = "Une politique qui permet la création de groupes de journaux dans CloudWatch Logs."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy",
          "logs:CreateLogGroup"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_logs_policy_attachment" {
  role       = data.aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_logs_policy.arn
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  role       = data.aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_cloudwatch_logs" {
  role       = data.aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_db_subnet_group" "default" {
  name       = "default-${data.aws_vpc.default.id}"
}

resource "aws_ecs_task_definition" "ms_proxy" {
  family                   = var.name_ecs_task_proxy
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  
  memory                   = "512"  
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn
  
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name  = "proxy"
    image = "${data.terraform_remote_state.ECR.outputs.repository_proxy}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/${var.name_ecs_task_proxy}}"
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "ms_scraper" {
  family                   = var.name_ecs_task_scraper
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" 
  memory                   = "512" 
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name  = "scraper"
    image = "${data.terraform_remote_state.ECR.outputs.repository_scraper}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group  = "true"
        awslogs-group         = "/ecs/${var.name_ecs_task_scraper}}"
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }

    environment = [
      { name = "APIGateway__Proxy", value = "http://${data.terraform_remote_state.CloudMap.outputs.url_proxy}.${data.terraform_remote_state.CloudMap.outputs.namespace_synomia_dev}" },
      { name = "APIGateway__Scraper", value = "http://${data.terraform_remote_state.CloudMap.outputs.url_scraper}.${data.terraform_remote_state.CloudMap.outputs.namespace_synomia_dev}" },
      { name = "APIGateway__ToolsCSharp", value = null },
      { name = "ApplicationInsights__InstrumentationKey", value = null },
      { name = "ConnectionStrings__Repository", value = "${data.terraform_remote_state.EC2.outputs.private_ip}" },
      { name = "Logging__IncludeScopes", value = var.Logging__IncludeScopes },
      { name = "Logging__LogLevel__Default", value = var.Loggin__LogLevel__Default },
      { name = "Puppeteer__ExecutablePath", value = var.Puppeteer__ExecutablePath },
      { name = "SmbFileProvider__Password", value = var.SmbFileProvider__Password },
      { name = "SmbFileProvider__Path", value = "${data.terraform_remote_state.FSx.outputs.fsx_file_system_dns_name}" },
      { name = "SmbFileProvider__UserName", value = var.SmbFileProvider__Username },
      { name = "WorkflowCore__DegreeOfParallelism", value = var.WorkflowCore__DegreeOfParallelism },
      { name = "WorkflowCore__Repository", value = "Server=${ split(":", data.terraform_remote_state.RDS.outputs.db_instance_endpoint)[0] };Database=${data.terraform_remote_state.RDS.outputs.db_identifier};User=${data.terraform_remote_state.RDS.outputs.db_username};Password=${data.terraform_remote_state.RDS.outputs.db_password}" },
    ]
  }])
}

resource "aws_ecs_service" "proxy" {
  name            = var.name_ecs_service_proxy
  cluster         = aws_ecs_cluster.microservices.id
  task_definition = aws_ecs_task_definition.ms_proxy.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.default.ids
    security_groups = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = data.terraform_remote_state.CloudMap.outputs.proxy_service_discovery_arn
  }

  deployment_controller {
    type = "ECS"
  }
}

resource "aws_appautoscaling_target" "ecs_proxy" {
  max_capacity       = 1
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.microservices.name}/${aws_ecs_service.proxy.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_proxy" {
  name               = "Scalingto0"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_proxy.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_proxy.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_proxy.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
  }
}

resource "aws_ecs_service" "scraper" {
  name            = var.name_ecs_service_scraper
  cluster         = aws_ecs_cluster.microservices.id
  task_definition = aws_ecs_task_definition.ms_scraper.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.default.ids
    security_groups = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = data.terraform_remote_state.CloudMap.outputs.scraper_service_discovery_arn
  }

  deployment_controller {
    type = "ECS"
  }
}

resource "aws_appautoscaling_target" "ecs_scraper" {
  max_capacity       = 1
  min_capacity       = 0
  resource_id        = "service/${aws_ecs_cluster.microservices.name}/${aws_ecs_service.scraper.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_scraper" {
  name               = "Scalingto0"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scraper.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scraper.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scraper.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
  }
} 