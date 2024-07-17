variable "aws_region" {
  description = "The AWS region"
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "The project credentials profile"
  default     = "enchant3dmango"
}

variable "aws_glue_database_name" {
  description = "The name of the Glue database"
  default     = "esdiel_db"
}

variable "aws_glue_etl_job_name" {
  description = "The name of the Glue job"
  default     = "Transform Esdiel Data"
}

variable "aws_glue_iam_role_name" {
  description = "The name of IAM Role of Glue"
  default     = "EsdielGlueRole"
}

variable "aws_glue_etl_script_location" {
  description = "The S3 location of the Glue script"
  default     = "s3://esdiel-bucket/scripts/glue_etl.py"
}

variable "aws_lambda_role_name" {
  description = "The name of IAM Role of Lambda"
  default     = "EsdielLambdaRole"
}
