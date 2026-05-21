# Production Support: CloudWatch Alarms for the SQS Dead Letter Queue
# Alerts the team if events fail to process 3 times and end up in the DLQ.

resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  alarm_name          = "s3-events-dlq-not-empty-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300" # 5 minutes
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm when there are messages in the Dead Letter Queue for Sequencing Events."

  dimensions = {
    QueueName = aws_sqs_queue.s3_events_dlq.name
  }

  # In production, this would point to an SNS topic notifying PagerDuty or Slack
  # alarm_actions = [aws_sns_topic.alerts.arn]
}
