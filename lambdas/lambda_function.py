import boto3
from os import environ

sns_client = boto3.client("sns")
topic_arn = environ["TOPIC_ARN"]

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == "INSERT":
            notify_received(record['dynamodb']['NewImage'])
        elif record['eventName'] == "REMOVE":
            notify_deleted(record['dynamodb']['OldImage'])
    
def notify_received(data):
    subject = "You received a message from {}".format(data['name']['S'])
    message = "Name: {}\nEmail: {}\nSubject: {}\nMessage: {}".format(data['name']['S'],data['email']['S'],data['subject']['S'],data['message']['S'])
    send_notification(subject,message)
    
def notify_deleted(data):
    subject = "A message received at {} has been deleted".format(data['timestamp']['S'])
    message = "Timestamp: {}\nName: {}\nEmail: {}\nSubject: {}\nMessage: {}".format(data['timestamp']['S'],data['name']['S'],data['email']['S'],data['subject']['S'],data['message']['S'])
    send_notification(subject,message)

def send_notification(subject,message):
    sns_client.publish(
        TopicArn=topic_arn,
        Message=message,
        Subject=subject
    )