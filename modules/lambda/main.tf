resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  assume_role_policy = file("${path.module}/lambda-role.json")
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"
  policy = file("${path.module}/policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "imgproc_resize_func" {
  function_name    = "resizer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "func.lambda_handler"
  runtime          = "python3.11"
  filename         = "${path.module}/func/lambda.zip"
  source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)
  timeout          = 600

  layers = [aws_lambda_layer_version.python_layer.arn]

  # lifecycle {
  #   create_before_destroy = true
  # }

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [var.security_group]
  }

  environment {
    variables = {
      FACE_FINDER_BUCKET_NAME = var.bucket_name
    }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/func/"
  output_path = "${path.module}/func/lambda.zip"
}

data "archive_file" "python" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/python.zip"
}

locals {
  layer_zip_path    = "${path.module}/python/python.zip"
  requirements_path = "${path.module}/python/requirements.txt"
  # requirements_path = "${path.root}/modules/lambda/python/requirements.txt"
  layer_name = "python-layer"
}

resource "aws_lambda_layer_version" "python_layer" {
  filename            = local.layer_zip_path
  layer_name          = local.layer_name
  compatible_runtimes = ["python3.10", "python3.11"]

  depends_on = [null_resource.lambda_layer]
}


resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1(local.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
      sudo set -e
      sudo apt-get update -y
      sudo apt install python3 python3-pip zip -y
      sudo rm -rf python
      mkdir python
      pip3 install -r ${local.requirements_path} -t python/
      zip -r ${data.archive_file.python.output_path} python/
    EOT
  }
}


resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "s3-bucket-image-event"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.event_rule
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}
