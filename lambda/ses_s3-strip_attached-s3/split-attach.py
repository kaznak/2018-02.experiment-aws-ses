
import boto3
import base64
import email
import urllib.parse

from datetime import datetime
from pytz import timezone
import hashlib
import os

print('Function Loaded')

s3 = boto3.resource('s3')
tz = 'Asia/Tokyo'
outpath = 'file/'

def lambda_handler(event, context):
    # Get the object from the event and show its content type
    print(event)
    print(context)
    
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        bucket_source = s3.Bucket(bucket)
        response = s3.meta.client.get_object(Bucket=bucket, Key=key)
        string_mail = response['Body'].read().decode('utf-8')
        email_message = email.message_from_string(string_mail)

        now = datetime.now(timezone(tz))
        nowstr = now.strftime("%Y-%m-%dT%H%M%S%Z")
        # <%Y-%m-%dT%H%M%S%Z>.<part_count>.<sha512hash>.<size>.<extension>

        partcount = 0

        for part in email_message.walk():
            if part.get_content_maintype() != 'image':
                # get only image file
                continue

            partcount += 1
            hash = hashlib.new('sha256')

            ifname = part.get_filename(failobj="")
            payload = part.get_payload(decode=True)

            _, extension = os.path.splitext(ifname)
            # TODO extension string must be checked
            hash.update(payload)

            okey = '.'.join([
                outpath,
                nowstr,
                str(partcount),
                hash.hexdigest(),
                str(len(payload))
            ]) + extension

            print([ifname, okey])
            
            obj = bucket_source.put_object(
                ACL='private',
                Key=okey, Body=payload,
                ContentType='text/plain'
            )

        return 'end'
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e

