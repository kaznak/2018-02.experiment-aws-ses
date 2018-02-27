
import boto3
import base64
import email
import urllib.parse

print('Loading function')

s3 = boto3.resource('s3')

def lambda_handler(event, context):
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    try:
        response = s3.meta.client.get_object(Bucket=bucket, Key=key)
        email_body = response['Body'].read().decode('utf-8')
        email_object = email.message_from_string(email_body)
        
        for part in email_object.walk():
            # ContentTypeがmultipartの場合は実際のコンテンツはさらに中のpartにあるので読み飛ばす
            if part.get_content_maintype() == 'multipart':
                continue
            # ファイル名の取得
            filename = part.get_filename()
            print(filename)
            # ファイル名がなければ飛ばす
            if not filename:
                continue
            else:
                # メールフォルダ内のfileディレクトリに添付ファイルを保存する
                attach_data = part.get_payload(decode=True)
                bucket_source = s3.Bucket(bucket)
                obj = bucket_source.put_object(ACL='private', Body=attach_data,
                                               Key='file' + "/" + filename, ContentType='text/plain')
                
        return 'end'
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
