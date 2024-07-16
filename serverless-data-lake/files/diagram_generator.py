from diagrams import Cluster, Diagram
from diagrams.aws.compute import Lambda
from diagrams.aws.analytics import GlueDataCatalog
from diagrams.aws.storage import SimpleStorageServiceS3Bucket
from diagrams.aws.analytics import GlueCrawlers
from diagrams.aws.analytics import Glue
from diagrams.aws.analytics import Athena


with Diagram("Serverless Data Lake", show=False):
    with Cluster("AWS"):
        s3_raw = SimpleStorageServiceS3Bucket("S3 Bucket (raw)")
        s3_transformed = SimpleStorageServiceS3Bucket("S3 Bucket (transformed)")
        glue_crawlers = GlueCrawlers("Glue Crawlers")
        glue_etl = Glue("Glue ETL")
        lambda_function = Lambda("Lambda")
        glue_data_catalog = GlueDataCatalog("Glue Data Catalog Database")
        athena = Athena("Athena")

    s3_raw >> lambda_function >> glue_crawlers
    s3_raw >> glue_crawlers >> [glue_etl, glue_data_catalog]
    glue_etl >> s3_transformed >> glue_data_catalog >> athena
