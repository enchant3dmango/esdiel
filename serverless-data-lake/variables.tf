variable "aws_region" {
  description = "The AWS region"
  default     = "ap-southeast-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store files"
  default     = "sdl"
}

variable "glue_database_name" {
  description = "The name of the Glue database"
  default     = "sdl_db"
}

variable "glue_job_name" {
  description = "The name of the Glue job"
  default     = "sdl_processing_job"
}

variable "glue_script_location" {
  description = "The S3 location of the Glue script"
  default     = "s3://sdl/assets/scripts/glue_processing_script.py"
}
