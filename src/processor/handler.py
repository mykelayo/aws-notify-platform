import json
import os
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)
sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    # Parse request body
    try:
        body = json.loads(event.get('body', '{}'))
        message = body.get('message', '')
    except Exception as e:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Invalid JSON'})
        }

    if not message:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing "message" field'})
        }

    # Publish to SNS
    try:
        response = sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps({'message': message, 'source': 'web-ui'}),
            MessageAttributes={
                'source': {
                    'DataType': 'String',
                    'StringValue': 'web-ui'
                }
            }
        )
        logger.info(f"Published message ID: {response['MessageId']}")
    except Exception as e:
        logger.error(f"Failed to publish: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Internal server error'})
        }

    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({'status': 'Message published'})
    }