import boto3
from os import environ

sns_client = boto3.client("sns")
topic_arn = environ["TOPIC_ARN"]

def notify_received(record):
    data = record['dynamodb']['NewImage']
    subject = "You received a message from {}".format(data['name']['S'])
    message = "Name: {}\nEmail: {}\nSubject: {}\nMessage: {}".format(data['name']['S'],data['email']['S'],data['subject']['S'],data['message']['S'])
    sns_client.publish(TopicArn=topic_arn,Subject=subject,Message=message)
    
def notify_deleted(record):
    data = record['dynamodb']['OldImage']
    subject = "A message received at {} has been deleted".format(data['timestamp']['S'])
    message = "Timestamp: {}\nName: {}\nEmail: {}\nSubject: {}\nMessage: {}".format(data['timestamp']['S'],data['name']['S'],data['email']['S'],data['subject']['S'],data['message']['S'])
    sns_client.publish(TopicArn=topic_arn,Subject=subject,Message=message)

func_map = {
    "INSERT": notify_received,
    "REMOVE": notify_deleted
}

def lambda_handler(event, context):
    for record in event['Records']:
        func_map[record['eventName']](record)
    