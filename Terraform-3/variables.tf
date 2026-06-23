variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

variable "queue_name" {
  description = "SQS Queue Name"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda Function Name"
  type        = string
}
