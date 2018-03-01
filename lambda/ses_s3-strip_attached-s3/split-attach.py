
import boto3
import base64
import email
import urllib.parse
from datetime import datetime
from pytz import timezone

print('Loading function')

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    # Get the object from the event and show its content type
    print(event)
    print(context)
    
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        response = s3.meta.client.get_object(Bucket=bucket, Key=key)
        string_mail = response['Body'].read().decode('utf-8')
        email_message = email.message_from_string(string_mail)

        partcount = 0
        now = datetime.now(timezone('Asia/Tokyo'))
        nowstr = now.strftime("%Y-%m-%dT%H%M%S%Z")
        print([partcount, nowstr])
        
        for part in email_message.walk():
            if part.get_content_maintype() == 'multipart':
                # Actual contents is in other part.
                continue

            partcount += 1

            ifname = part.get_filename(failobj="")
            
            ofname = '.'.join([nowstr,str(partcount),ifname])

            print([ifname, ofname])
            
            attach_data = part.get_payload(decode=True)
            bucket_source = s3.Bucket(bucket)
            obj = bucket_source.put_object(ACL='private', Body=attach_data,
                                           Key='file' + "/" + ofname, ContentType='text/plain')

        return 'end'
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
