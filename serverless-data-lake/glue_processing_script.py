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
datasource = glueContext.create_dynamic_frame.from_options(
    format_options={"separator": ","},
    connection_type="s3",
    format="csv",
    connection_options={"paths": ["s3://sdl/"], "recurse": True},
    transformation_ctx="datasource",
)

# Apply transformations
applymapping = ApplyMapping.apply(
    frame=datasource,
    mappings = [
        ("name", "string", "name", "string"),
        ("location", "string", "nationality", "string"),
        ("age", "int", "age", "int"),
    ],
    transformation_ctx = "applymapping"
)

# Write the transformed data to S3
datasink = glueContext.write_dynamic_frame.from_options(
    frame=applymapping,
    connection_type="s3",
    connection_options={"path": "s3://sdl-transformed/"},
    format="parquet",
    transformation_ctx="datasink",
)

job.commit()
