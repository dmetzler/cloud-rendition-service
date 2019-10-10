Cloud Rendition Service
=======================


This is an implementation of the blog post found here: https://aws.amazon.com/blogs/networking-and-content-delivery/resizing-images-with-amazon-cloudfront-lambdaedge-aws-cdn-blog/


How To Build The Lambdas?
-------------------------
This command will build the Docker image used to compile nodes and the install and package the Lambda functions in the dist directory

```console
# make docker
# make
```


How To Deploy?
--------------

We first have to create an S3 bucket that will holds the deployment file that were built in the previous step.

```console
# aws s3 mb s3://my-deployment-bucket
```

Then we use the deploy target:
```console
# DEPLOYMENT_BUCKET=my-deployment-bucket make deploy
```

Other parameters for the `deploy` target are:

 * `STACK_NAME`: Name of the CloudFormation stack that will be deployed
 * `IMAGE_BUCKET`: Prefix of the S3 bucket where image will uploaded

The `deploy` target issues a describe stack command at the end:

```json
{
    "Stacks": [
        {
            "StackId": "arn:aws:cloudformation:us-east-1:XXXXXXXXXXXXX:stack/image-resize/aaaaaaaaaaaaaa",
            "DriftInformation": {
                "StackDriftStatus": "NOT_CHECKED"
            },
            "LastUpdatedTime": "2019-10-10T21:41:44.411Z",
            "Tags": [],
            "Outputs": [
                {
                    "ExportName": "image-resize-ImageBucket",
                    "OutputKey": "ImageBucket",
                    "OutputValue": "image-resize-XXXXXXXXXXXXX-us-east-1"
                },
                {
                    "ExportName": "image-resize-",
                    "OutputKey": "CloudFrontDomain",
                    "OutputValue": "xxxxxxxx.cloudfront.net"
                },
                {
                    "ExportName": "image-resize-MyDistribution",
                    "OutputKey": "Distribution",
                    "OutputValue": "XXXXXXXXXXXXX"
                }
            ],
            "EnableTerminationProtection": false,
            "CreationTime": "2019-10-10T20:45:44.728Z",
            "Capabilities": [
                "CAPABILITY_IAM"
            ],
            "StackName": "image-resize",
            "NotificationARNs": [],
            "StackStatus": "UPDATE_COMPLETE",
            "DisableRollback": false,
            "ChangeSetId": "arn:aws:cloudformation:us-east-1:XXXXXXXXXXXXX:changeSet/awscli-cloudformation-package-deploy-xxxxxx",
            "RollbackConfiguration": {}
        }
    ]
}
```

The important data are in the outputs part.

How To Use?
-----------

We first have to upload some pictures in the S3 image bucket (see `ImageBucket` output of our stack) using whatever tool (S3 sync, S3 copy...).

```console
# aws s3 cp mypicture.png s3://image-resize-XXXXXXXXXXXXX-us-east-1/images/mypicture.png
```

Then we can access that picture with the CloudFront domain that has been create (see `CloudFrontDomain` of our stack).

```console
# wget https://xxxxxx.cloudfront.net/images/mypicture.png
```

If we want a resized versions:

```console
# wget https://xxxxxx.cloudfront.net/images/mypicture.png?d=100x100
```



