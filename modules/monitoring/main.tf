# Optional monitoring module for VPC
variable "vpc_id" {
  description = "VPC ID to monitor"
  type        = string
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs to monitor"
  type        = list(string)
  default     = []
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention period for VPC Flow Logs"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to monitoring resources"
  type        = map(string)
  default     = {}
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/flowlogs/${var.vpc_id}"
  retention_in_days = var.flow_logs_retention_days
  tags              = var.tags
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "vpc-flow-logs-role-${var.vpc_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "vpc-flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

# VPC Flow Logs
resource "aws_flow_log" "vpc" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
  tags            = var.tags
}

# CloudWatch Alarms for NAT Gateways
resource "aws_cloudwatch_metric_alarm" "nat_gateway_connection_count" {
  for_each = toset(var.nat_gateway_ids)
  
  alarm_name          = "nat-gateway-connection-count-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ActiveConnectionCount"
  namespace           = "AWS/NatGateway"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "50000"
  alarm_description   = "This metric monitors NAT Gateway connection count"
  alarm_actions       = []

  dimensions = {
    NatGatewayId = each.value
  }

  tags = var.tags
}

# Output
output "flow_log_id" {
  description = "VPC Flow Log ID"
  value       = var.enable_flow_logs ? aws_flow_log.vpc[0].id : null
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}