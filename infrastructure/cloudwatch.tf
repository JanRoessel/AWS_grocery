# CloudWatch Monitoring & Alarme
#
# Ich habe hier die wichtigsten Metriken überwacht:
# - CPU von EC2 und RDS (wenn die Instanz zu heiss läuft)
# - Health Status vom Load Balancer (ob Targets erreichbar sind)
# - Freier Speicher auf RDS (darf nicht ausgehen)
#
# Die Alarme schicken Benachrichtigungen an eine E-Mail-Adresse
# (muss man in terraform.tfvars setzen).

# SNS Topic — hier landen alle Alarm-Benachrichtigungen
resource "aws_sns_topic" "alarms" {
  name = "${var.app_name}-cloudwatch-alarms"

  tags = { Name = "${var.app_name}-cloudwatch-alarms" }
}

# SNS Subscription — E-Mail-Benachrichtigung
# Achtung: Man muss die Bestätigungsmail von AWS bestätigen,
# sonst kommen keine Benachrichtigungen an!
resource "aws_sns_topic_subscription" "email" {
  count = var.alarm_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# --- Alarm 1: EC2 CPU zu hoch ---
resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "${var.app_name}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 Minuten
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU über 80% für 10 Minuten"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  tags = { Name = "${var.app_name}-ec2-cpu-high" }
}

# --- Alarm 2: RDS CPU zu hoch ---
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.app_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU über 80% für 10 Minuten"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  tags = { Name = "${var.app_name}-rds-cpu-high" }
}

# --- Alarm 3: ALB hat unhealthy Targets ---
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy" {
  alarm_name          = "${var.app_name}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnhealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "ALB hat mindestens 1 unhealthy Target"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    TargetGroup  = aws_lb_target_group.app.arn_suffix
    LoadBalancer = aws_lb.app.arn_suffix
  }

  tags = { Name = "${var.app_name}-alb-unhealthy-hosts" }
}

# --- Alarm 4: RDS Speicher wird knapp ---
resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "${var.app_name}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2000000000  # 2 GB in Bytes
  alarm_description   = "RDS Free Storage unter 2 GB"
  alarm_actions       = [aws_sns_topic.alarms.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  tags = { Name = "${var.app_name}-rds-storage-low" }
}
