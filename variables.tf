variable "region" {
  default = "us-east-1"
  description = "Region to deploy Lambda function. Should be same region as source bucket."
}
variable "src_bucket_name" {
  type = "string"
  description = "Name of source bucket"
}
variable "dest_bucket_name" {
  type = "string"
  description = "Name of destination bucket"
}
variable "lambda_function_name" {
  type = "string"
  description = "Name of Lambda function"
}
variable "lambda_iam_role_name" {
  type = "string"
  description = "IAM role that allows Lambda to move objects between buckets"
}
