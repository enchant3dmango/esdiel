import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Read CSV file from S3
datasource0 = glueContext.create_dynamic_frame.from_options(
    format_options={"separator": ","},
    connection_type="s3",
    format="csv",
    connection_options={"paths": ["s3://sdl/"], "recurse": True},
    transformation_ctx="datasource0",
)

# Apply transformations
applymapping1 = ApplyMapping.apply(
    frame=datasource0,
    mappings = [
        ("name", "string", "name", "string"),
        ("location", "string", "nationality", "string"),
        ("age", "int", "age", "int"),
    ],
    transformation_ctx = "applymapping1"
)

# Write the transformed data to S3
datasink2 = glueContext.write_dynamic_frame.from_options(
    frame=applymapping1,
    connection_type="s3",
    connection_options={"path": "s3://sdl-transformed/"},
    format="parquet",
    transformation_ctx="datasink2",
)

job.commit()
