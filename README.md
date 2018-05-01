# cascading-bucket
Simple proof-of-concept to move files between buckets across accounts via Lambda function. Repo contains the Python source code for file movement and the Terraform templates to deploy Lambda in any environment.

## Table of Content
1. [Lambda Setup](#lambda)
2. [Terraform Installation](#terraform)
3. [Variable Configuration](#configuration)
4. [Ready, Set, and Apply](#apply)

<a name="lambda"></a>
## Lambda Setup
Main purpose of this Lambda is to move objects in the source bucket, which the function is configured as the notification endpoint, when objects are uploaded to the bucket. When objects are uploaded to the bucket, it would trigger the attached Lambda function with information on the upload event, including objects' information. The function will make a series of API calls to copy objects from source bucket to a destination bucket, specified as environment variable `DEST_BUCKET`, and upon success, it will delete the objects from source bucket.

Provided that both source and destination buckets exist, the Terraform templates in this repo will perform necessary Lambda function deployment and configuration. The source code is generic, not tied to any specific AWS environment, and can be setup for multitude of bucket pairs.

<a name="terraform"></a>
## Terraform Installation
#### On Mac
Hopefully if you're using a Mac, you installed Homebrew by now. If not, please follow the instructions [here](https://docs.brew.sh/Installation.html)
to install it. Once installed, run the following command:
```
brew install terraform
```
#### On other OS platforms
Find other OS installation instructions for Terraform [here](https://www.terraform.io/intro/getting-started/install.html).

<a name="configuration"></a>
## Variable Configuration
Variables define the parameterization of Terraform configurations. For this project, variable assignments are collected in separate `terraform.tfvars` file located within the same project directory and Terraform will automatically populate them. Refer below for sample file.
```
region = "us-east-1"
src_bucket_name = "accountA-bucket"
dest_bucket_name = "accountB-bucket"
lambda_function_name = "cascading-function"
lambda_iam_role_name = "lambda-s3-role"
```
All values above are required for the proper configuration and deployment of the Lambda function. Additional things to consider when filling out the variable values:
* Terraform to provision Lambda in same AWS account that owns the source bucket.
* `region` specifies where the Lambda function will be deployed. This value should also be the region where `src_bucket_name` resides; function must be in same region as the source bucket.
* Ensure that role specified in `lambda_iam_role_name` has appropriate S3 actions; `s3:GetObject`, `s3:PutObject`, `s3:PutObjectAcl`. Role must be able to assign canned ACL `bucket-owner-full-control` to objects during upload.
* Whitelist specific S3 actions for Lambda IAM role if source and/or destination buckets have restrictive bucket policies.

Note: Best practice to never commit `.tfvars` files to a source control as it may contain sensitive information about an environment.

Note: Assume that the environment variable `AWS_PROFILE` is set to a designated profile with proper AWS credentials to perform actions (i.e. access S3 buckets). Hence the files do not specify any profile or secret access keys because default behavior of Terraform will use credentials of `AWS_PROFILE`.

<a name="apply"></a>
## Ready, Set, and Apply
Initialization is required for new setup of Terraform and addition, modification, or deletion of configuration. In this project, backend configuration is located in `terraform.tf`. Make sure that the file is properly configured and then initialization the backend with the following command:
```
terraform init
```

When everything is configured correctly, we are ready to plan the infrastructure and preview what actions Terraform will take before it provisions.
```
terraform plan
terraform apply
```
