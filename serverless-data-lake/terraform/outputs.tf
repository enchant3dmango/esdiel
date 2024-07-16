output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda_function.lambda_function_name
}

output "glue_etl_job_name" {
  description = "The name of the Glue job"
  value       = aws_glue_job.glue_etl_job.name
}
