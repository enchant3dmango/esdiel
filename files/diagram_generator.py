from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import Lambda
from diagrams.aws.analytics import GlueDataCatalog
from diagrams.aws.storage import SimpleStorageServiceS3Bucket
from diagrams.aws.analytics import GlueCrawlers
from diagrams.aws.analytics import Glue
from diagrams.aws.analytics import Athena
from diagrams.custom import Custom


dashed_line = {
    "style": "dashed"
}

transparent_bg = {
    "bgcolor": "transparent",
    "splines":"spline",
}

small_font = {
    "fontsize": "10"
}


with Diagram("Esdiel", show=False, graph_attr=transparent_bg):
    with Cluster(""):
        with Cluster("AWS"):
            s3_raw = SimpleStorageServiceS3Bucket("S3 Bucket (raw)")
            s3_transformed = SimpleStorageServiceS3Bucket("S3 Bucket (transformed)")
            glue_crawlers = GlueCrawlers("Glue Crawlers")
            glue_etl = Glue("Glue ETL")
            lambda_function = Lambda("Lambda")
            glue_database = GlueDataCatalog("Glue Database")
            athena = Athena("Athena")

            s3_raw >> lambda_function >> glue_etl
            s3_raw >> glue_crawlers >> [glue_etl, glue_database]
            s3_raw >> Edge(**dashed_line) >>glue_database
            glue_etl >> s3_transformed >> Edge(**dashed_line) >> glue_database
            s3_transformed >> glue_crawlers
            glue_database >> athena
        
        terraform = Custom("Managed using Terraform", "./terraform.png", **small_font)

        terraform
