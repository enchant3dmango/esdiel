# S3 Bucket
resource "aws_s3_bucket" "sdl_bucket" {
  bucket = var.s3_bucket_name
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "sdl_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "sdl_lambda_policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["logs:*", "s3:*", "glue:*"],
        Resource = "*",
        Effect   = "Allow",
      },
    ],
  })
}

# Lambda Function
resource "aws_lambda_function" "sdl_handler" {
  filename         = "lambda.zip"
  function_name    = "sdl_handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      BUCKET        = aws_s3_bucket.sdl_bucket.bucket
      GLUE_JOB_NAME = var.glue_job_name
    }
  }
}

# S3 Bucket Notification
resource "aws_s3_bucket_notification" "sdl_bucket_notification" {
  bucket = aws_s3_bucket.sdl_bucket.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.sdl_handler.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Glue Database
resource "aws_glue_catalog_database" "default" {
  name = var.glue_database_name
}

# Glue Job
resource "aws_glue_job" "processing" {
  name     = var.glue_job_name
  role_arn = aws_iam_role.lambda_exec.arn

  command {
    name            = "glueetl"
    script_location = var.glue_script_location
    python_version  = "3"
  }

  default_arguments = {
    "--job-bookmark-option" = "job-bookmark-enable"
  }
}
