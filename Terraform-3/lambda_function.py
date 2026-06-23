import json

def lambda_handler(event, context):

    for sqs_record in event["Records"]:

        body = json.loads(sqs_record["body"])

        for s3_record in body["Records"]:

            bucket_name = s3_record["s3"]["bucket"]["name"]
            file_name = s3_record["s3"]["object"]["key"]

            print(f"Bucket Name: {bucket_name}")
            print(f"Uploaded File: {file_name}")

    return {
        "statusCode": 200
    }
