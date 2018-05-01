provider "aws" {
  region = "${var.region}"
}

data "aws_s3_bucket" "src_bucket" {
  bucket = "${var.src_bucket_name}"
}

data "aws_iam_role" "lambda_role" {
  name = "${var.lambda_iam_role_name}"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.function.arn}"
  principal = "s3.amazonaws.com"
  source_arn = "${data.aws_s3_bucket.src_bucket.arn}"
}

resource "aws_lambda_function" "function" {
  filename = "lambda_function.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  function_name = "${var.lambda_function_name}"
  role = "${data.aws_iam_role.lambda_role.arn}"
  handler = "lambda_function.lambda_handler"
  runtime = "python2.7"

  environment {
    variables = {
      DEST_BUCKET = "${var.dest_bucket_name}"
    }
  }
}

resource "aws_s3_bucket_notification" "notification" {
  bucket = "${var.src_bucket_name}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.function.arn}"
    events = ["s3:ObjectCreated:*"]
  }
}
