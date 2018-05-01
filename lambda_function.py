import boto3
from botocore.exceptions import ClientError

import urllib
import os
import logging

log = logging.getLogger()
client = boto3.client('s3')
dest_bucket = os.environ['DEST_BUCKET']

def lambda_handler(event, context):
    move_object(event, context)

def move_object(event, context):
    obj_list = []

    for e in event['Records']:
        s = e['s3']
        src_bucket = s['bucket']['name']
        obj_key = urllib.unquote_plus(s['object']['key'])
        copy_source = {
            'Bucket': src_bucket,
            'Key': obj_key
        }
        if copy_object(copy_source, dest_bucket, obj_key) is not None:
            obj_list.append({'Key': obj_key})

    delete_objects(src_bucket, obj_list)

def copy_object(copy_source, dest_bucket, obj_key):
    try:
        client.copy(copy_source, dest_bucket, obj_key,
            {'ACL': 'bucket-owner-full-control', 'ServerSideEncryption': 'AES256'})
        return obj_key
    except ClientError as e:
        log.exception(
            'Exception copying object %s to %s', obj_key, dest_bucket)
        return None

def delete_objects(bucket_name, obj_list):
    try:
        client.delete_objects(
            Bucket=bucket_name,
            Delete={
                'Objects': obj_list
            }
        )
    except ClientError as e:
        log.exception(
            'Exception deleting objects from bucket')
        raise
