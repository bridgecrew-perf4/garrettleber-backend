from decimal import Decimal
import os
import boto3

#Code used to pull variable created from terraform, but this created issues with the unit tests
#VISITORS_TABLE = os.environ['VISITORS_TABLE']

def lambda_handler(event, context):
  dynamodbclient=boto3.resource('dynamodb', region_name='us-east-1')
  table = dynamodbclient.Table("Visitors")
  table.update_item(
    Key={
        'website':'garrettleber.com'
    },
    UpdateExpression="ADD hits :val1",
    ExpressionAttributeValues={
        ':val1': Decimal(1)
    },
    ReturnValues="UPDATED_NEW"
  )

  response = table.get_item(Key={'website':'garrettleber.com'})
  data = response['Item']['hits']


  return {
      "isBase64Encoded": "false",
      "statusCode": 200,
      "headers": { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Credentials": "true" },
      "body": data
      }
