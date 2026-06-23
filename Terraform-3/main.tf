# S3 Bucket

resource "aws_s3_bucket" "uploads" {
  bucket = var.bucket_name
}

# SQS Queue

resource "aws_sqs_queue" "file_queue" {
  name = var.queue_name
}


# SQS Policy


resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.file_queue.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "s3.amazonaws.com"
        }

        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.file_queue.arn

        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.uploads.arn
          }
        }
      }
    ]
  })
}


# S3 -> SQS Notification


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploads.id

  queue {
    queue_arn = aws_sqs_queue.file_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_sqs_queue_policy.allow_s3
  ]
}


# IAM Role

resource "aws_iam_role" "lambda_role" {
  name = "lambda-s3-sqs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


# CloudWatch Logs Policy


resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# SQS Permissions

resource "aws_iam_role_policy" "sqs_access" {
  name = "lambda-sqs-access"

  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]

        Resource = aws_sqs_queue.file_queue.arn
      }
    ]
  })
}

# Lambda ZIP


data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda Function

resource "aws_lambda_function" "file_processor" {
  function_name = var.lambda_function_name

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role    = aws_iam_role.lambda_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"
}


# SQS -> Lambda Trigger


resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.file_queue.arn

  function_name = aws_lambda_function.file_processor.arn

  batch_size = 1
}
