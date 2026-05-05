import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event):
    """Process SQS messages (each event['Records'] is a list)"""
    for record in event['Records']:
        # SQS record body is the SNS message (if raw delivery enabled)
        message_body = record.get('body', '{}')
        logger.info(f"Received message: {message_body}")

        # TODO: Parse JSON, validate, write to Aurora
        # For now, just log success.

    return {
        'statusCode': 200,
        'body': json.dumps('Processed successfully')
    }