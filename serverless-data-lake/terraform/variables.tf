variable "aws_region" {
  description = "The AWS region"
  default     = "ap-southeast-1"
}

variable "aws_glue_database_name" {
  description = "The name of the Glue database"
  default     = "sdl_db"
}

variable "aws_glue_etl_job_name" {
  description = "The name of the Glue job"
  default     = "sdl_etl_job"
}

variable "aws_glue_etl_script_location" {
  description = "The S3 location of the Glue script"
  default     = "s3://esdiel-bucket/scripts/glue_etl.py"
}
