import logging
import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from awsglue.job import Job
from pyspark.sql.types import StringType, IntegerType
from pyspark.sql.functions import col

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
ReadSourceCSV = glueContext.create_dynamic_frame.from_options(
    format_options={"quoteChar": '"', "withHeader": True, "separator": ","},
    connection_type="s3",
    format="csv",
    connection_options={"paths": ["s3://esdiel-bucket/data/"], "recurse": True},
    transformation_ctx="ReadSourceCSV",
)

# Log schema and data from source
logger.info("Schema of the input data:")
ReadSourceCSV.printSchema()

logger.info("Rows from the input data:")
ReadSourceCSV.show()

# Convert DynamicFrame to DataFrame for type casting
dataframe = ReadSourceCSV.toDF()

# Cast columns to appropriate types
dataframe = dataframe.withColumn("name", col("name").cast(StringType())) \
       .withColumn("location", col("location").cast(StringType())) \
       .withColumn("age", col("age").cast(IntegerType()))

# Apply field mapping (renaming columns)
dataframe = dataframe.withColumnRenamed("location", "country")

# Convert back to DynamicFrame
ApplyFieldMapping = DynamicFrame.fromDF(dataframe, glueContext, "ApplyFieldMapping")

# Log schema and data after field mapping
logger.info("Schema of the transformed data:")
ApplyFieldMapping.printSchema()

logger.info("Rows from the transformed data:")
ApplyFieldMapping.show()

# Write the mapped data to S3
WriteMappedData = glueContext.write_dynamic_frame.from_options(
    frame=ApplyFieldMapping,
    connection_type="s3",
    format="glueparquet",
    connection_options={
        "path": "s3://esdiel-bucket-transformed/data/",
        "partitionKeys": [],
    },
    format_options={"compression": "snappy"},
    transformation_ctx="WriteMappedData",
)

job.commit()

logger.info("Job completed successfully.")
