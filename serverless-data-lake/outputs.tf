output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.sdl_bucket.bucket
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.handler.function_name
}

output "glue_job_name" {
  description = "The name of the Glue job"
  value       = aws_glue_job.processing.name
}
