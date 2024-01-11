variable "name_ecs_task_proxy" {
  type = "string"
  default = "ms-proxy"
}

variable "name_ecs_task_scraper" {
  type = "string"
  default = "ms-scraper"
}

variable "region" {
  type = "string"
  default = "eu-west-3"
}

variable "name_ecs_cluster" {
  type = "string"
  default = "microservices"
}

variable "name_ecs_service_proxy" {
  type = "string"
  default = "proxy"
}

variable "name_ecs_service_scraper" {
  type = "string"
  default = "scraper"
}

variable "SmbFileProvider__Password" {
    type = "string"
    default = ""
}

variable "SmbFileProvider__Username" {
    type = "string"
    default = "admin"
}

variable "WorkflowCore__DegreeOfParallelism" {
    type = "string"
    default = "2"
}

variable "Puppeteer__ExecutablePath" {
    type = "string"
    default = "/usr/bin/chromium"
}

variable "Loggin__LogLevel__Default" {
    type = "string"
    default = "Trace"
}

variable "Logging__IncludeScopes" {
    type = "string"
    default = "true"
}