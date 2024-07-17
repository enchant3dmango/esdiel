import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Get job arguments
args = getResolvedOptions(sys.argv, ["JOB_NAME"])

# Initialize Spark and Glue context
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
    connection_options={"paths": ["s3://esdiel-bucket/data"], "recurse": True},
    transformation_ctx="datasource",
)

# Log the schema of the input data
datasource.printSchema()

# Show some sample rows from the input data
datasource.show()

# Apply transformations
applymapping = ApplyMapping.apply(
    frame=datasource,
    mappings=[
        ("name", "string", "name", "string"),
        ("location", "string", "nationality", "string"),
        ("age", "int", "age", "int"),
    ],
    transformation_ctx="applymapping",
)

# Log the schema of the transformed data
applymapping.printSchema()

# Show some sample rows from the transformed data
applymapping.show()

# Write the transformed data to S3
datasink = glueContext.write_dynamic_frame.from_options(
    frame=applymapping,
    connection_type="s3",
    connection_options={"path": "s3://esdiel-transformed-bucket/data"},
    format="parquet",
    transformation_ctx="datasink",
)

# Commit the job
job.commit()
