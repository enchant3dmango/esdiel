# S3 Bucket
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "esdiel-bucket"
}

# S3 Bucket Notification
module "notifications" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "4.1.2"

  bucket = module.s3_bucket.s3_bucket_id

  lambda_notifications = {
    lambda_function = {
      function_arn  = module.lambda_function.lambda_function_arn
      function_name = module.lambda_function.lambda_function_name
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "data/"
      filter_suffix = ".csv"
    }
  }
}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "SDLLambdaRole"
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
  name = "SDLLambdaRolePolicy"
  role = aws_iam_role.lambda_role.id
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
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.7.0"

  function_name = "sdl_handler"
  description   = "My awesome serverless data lake (sdl) handler"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  create_package         = false
  local_existing_package = "../lambda.zip"

  role_name = aws_iam_role.lambda_role.name

  environment_variables = {
    BUCKET        = module.s3_bucket.s3_bucket_id
    GLUE_JOB_NAME = var.aws_glue_etl_job_name
  }

  allowed_triggers = {
    s3 = {
      service       = "s3"
      source_arn    = module.s3_bucket.s3_bucket_arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "data/"
      filter_suffix = ".csv"
    }
  }
}


# Glue Database
resource "aws_glue_catalog_database" "default" {
  name = var.aws_glue_database_name
}

# Glue Job
resource "aws_glue_job" "glue_etl_job" {
  name     = var.aws_glue_etl_job_name
  role_arn = module.lambda_function.lambda_role_arn

  command {
    name            = "glueetl"
    script_location = var.aws_glue_etl_script_location
    python_version  = "3"
  }

  default_arguments = {
    "--job-bookmark-option" = "job-bookmark-enable"
  }
}
