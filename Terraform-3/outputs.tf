output "bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

output "queue_name" {
  value = aws_sqs_queue.file_queue.name
}

output "lambda_name" {
  value = aws_lambda_function.file_processor.function_name
}
