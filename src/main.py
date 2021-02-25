from decimal import Decimal
import os
import boto3


VISITORS_TABLE = os.environ['VISITORS_TABLE']

def lambda_handler(event, context):
  dynamodbclient=boto3.resource('dynamodb')
  table = dynamodbclient.Table(VISITORS_TABLE)
  table.update_item(
    Key={
        'website':'imkumpy.com'
    },
    UpdateExpression="ADD hits :val1",
    ExpressionAttributeValues={
        ':val1': Decimal(1)
    },
    ReturnValues="UPDATED_NEW"
  )

  response = table.get_item(Key={'website':'imkumpy.com'})
  data = response['Item']['hits']


  return {
      "isBase64Encoded": "false",
      "statusCode": 200,
      "headers": { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Credentials": "true" },
      "body": data
      }
