import json
import os
import logging
import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Environment variables set by Terraform
CLUSTER_ARN = os.environ.get('AURORA_CLUSTER_ARN')
SECRET_ARN = os.environ.get('AURORA_SECRET_ARN')
DATABASE_NAME = os.environ.get('DATABASE_NAME', 'notifications')

rds_data = boto3.client('rds-data')

def lambda_handler(event, context):
    for record in event['Records']:
        message_body = record.get('body', '{}')
        logger.info(f"Processing message: {message_body}")

        # Parse JSON payload
        try:
            payload = json.loads(message_body)
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON: {e}")
            # Do not retry – malformed message, send to DLQ by raising exception?
            # SQS redrive policy will move to DLQ after maxReceiveCount.
            raise

        # Insert into Aurora using Data API
        if CLUSTER_ARN and SECRET_ARN:
            try:
                sql = """
                    INSERT INTO messages (payload)
                    VALUES (CAST(:payload AS JSONB))
                """
                response = rds_data.execute_statement(
                    resourceArn=CLUSTER_ARN,
                    secretArn=SECRET_ARN,
                    database=DATABASE_NAME,
                    sql=sql,
                    parameters=[
                        {
                            'name': 'payload',
                            'value': {'stringValue': json.dumps(payload)},
                            'typeHint': 'JSON'
                        }
                    ]
                )
                logger.info(f"Insert successful: {response}")
            except ClientError as e:
                logger.error(f"Data API error: {e}")
                raise  # triggers retry
        else:
            logger.warning("Aurora credentials not configured – skipping insert")

    return {'statusCode': 200}