import sys
import logging
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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
    format_options={"separator": ",", "skip.header.line.count": "1"},
    connection_type="s3",
    format="csv",
    connection_options={"paths": ["s3://esdiel-bucket/data"], "recurse": True},
    transformation_ctx="datasource",
)

# Log schema and data from source
logger.info("Schema of the input data:")
datasource.printSchema()

logger.info("Rows from the input data:")
datasource.show()

# Verify the schema and data types of the input data
schema = datasource.schema()
logger.info("Schema fields:")
for field in schema.fields:
    logger.info(f"{field.name}: {field.dataType}")

# Apply field mapping
applymapping = ApplyMapping.apply(
    frame=datasource,
    mappings=[
        ("name", "string", "name", "string"),
        ("location", "string", "nationality", "string"),
        ("age", "int", "age", "int"),
    ],
    transformation_ctx="applymapping",
)

# Log schema and data after field mapping
logger.info("Schema of the transformed data:")
applymapping.printSchema()

logger.info("Rows from the transformed data:")
applymapping.show()

# Write the transformed data to S3
datasink = glueContext.write_dynamic_frame.from_options(
    frame=applymapping,
    connection_type="s3",
    connection_options={"path": "s3://esdiel-bucket-transformed/data"},
    format="csv",
    transformation_ctx="datasink",
)

# Commit the job
job.commit()

logger.info("Job completed successfully.")
