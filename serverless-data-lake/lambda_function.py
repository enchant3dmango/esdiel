import boto3
import os


def lambda_handler(event, context):
    glue = boto3.client("glue")
    response = glue.start_job_run(JobName=os.environ["GLUE_JOB_NAME"])

    return response
