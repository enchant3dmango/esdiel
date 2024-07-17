data "aws_caller_identity" "current" {}

# S3 Bucket
module "s3_esdiel" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "esdiel-bucket"
}

module "s3_esdiel_transformed" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "esdiel-bucket-transformed"
}

# S3 Bucket Notification
module "notifications" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "4.1.2"

  bucket = module.s3.s3_bucket_id

  lambda_notifications = {
    lambda_function = {
      function_arn  = module.lambda.lambda_function_arn
      function_name = module.lambda.lambda_function_name
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "data/"
      filter_suffix = ".csv"
    }
  }
}

# Lambda Function
module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.7.0"

  function_name      = "esdiel-handler"
  description        = "My awesome serverless data lake (Esdiel) handler"
  handler            = "lambda_function.handler"
  runtime            = "python3.8"
  role_name          = var.aws_lambda_role_name
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:*",
          "s3:*",
          "glue:*"
        ],
        Resource = "*",
        Effect   = "Allow",
      },
    ],
  })

  assume_role_policy_statements = {
    account_ar = {
      effect  = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        account_principal = {
          type        = "AWS",
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      }
    }

    glue_ar = {
      effect  = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        glue = {
          type        = "Service",
          identifiers = ["glue.amazonaws.com"]
        }
      }
    }
  }

  create_current_version_allowed_triggers = false
  create_package                          = false
  local_existing_package                  = "../lambda.zip"

  environment_variables = {
    BUCKET        = module.s3.s3_bucket_id
    GLUE_JOB_NAME = var.aws_glue_etl_job_name
  }

  allowed_triggers = {
    s3 = {
      service       = "s3"
      source_arn    = module.s3.s3_bucket_arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "data/"
      filter_suffix = ".csv"
    }
  }
}

# Glue Database
resource "aws_glue_catalog_database" "esdiel_database" {
  name = var.aws_glue_database_name
}

# Glue Table for Raw Data
resource "aws_glue_catalog_table" "esdiel_data_raw" {
  name          = "esdiel-data-raw"
  database_name = aws_glue_catalog_database.esdiel_database.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    "classification" = "csv"
  }

  storage_descriptor {
    location          = "s3://esdiel-bucket/data"
    input_format      = "org.apache.hadoop.mapred.TextInputFormat"
    output_format     = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed        = false
    number_of_buckets = -1
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "field.delim" = ","
      }
    }
    stored_as_sub_directories = false
    columns {
      name = "name"
      type = "string"
    }
    columns {
      name = "location"
      type = "string"
    }

    columns {
      name = "age"
      type = "int"
    }
  }
}

# Glue Table for Tranformed Data
resource "aws_glue_catalog_table" "esdiel_data_transformed" {
  name          = "esdiel_data_transformed"
  database_name = aws_glue_catalog_database.esdiel_database.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    "classification" = "parquet"
  }

  storage_descriptor {
    location          = "s3://esdiel-transformed-bucket/data"
    input_format      = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format     = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    compressed        = false
    number_of_buckets = -1
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters            = {}
    }
    stored_as_sub_directories = false

    columns {
      name = "name"
      type = "string"
    }

    columns {
      name = "nationality"
      type = "string"
    }

    columns {
      name = "age"
      type = "int"
    }
  }
}

# Glue Job
resource "aws_glue_job" "glue_etl_job" {
  name     = var.aws_glue_etl_job_name
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = var.aws_glue_etl_script_location
    python_version  = "3"
  }

  default_arguments = {
    "--job-bookmark-option" = "job-bookmark-enable"
  }
}

# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name = var.aws_glue_iam_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
      },
    ],
  })
}

# IAM Role Policy for Glue
resource "aws_iam_role_policy" "glue_access_policy" {
  role = aws_iam_role.glue_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::esdiel-bucket/*",
          "arn:aws:s3:::esdiel-transformed-bucket/*"
        ],
      },
      {
        Action = "s3:ListBucket",
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::esdiel-bucket",
          "arn:aws:s3:::esdiel-transformed-bucket"
        ],
      },
    ],
  })
}
