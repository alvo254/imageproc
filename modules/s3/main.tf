resource "aws_iam_role" "bucket_role" {
  assume_role_policy = file("${path.module}/bucket_role.json")
  name = "bucket_role"
}

resource "aws_iam_policy" "policy" {
    name   = "bucket_policy"
    policy = file("${path.module}/bucket_policy.json.tpl")
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.bucket_role.name
}

resource "aws_s3_bucket" "imgproc_unsized" {
    bucket = var.unsized_img_bucket
    force_destroy = true

  tags = {
    Name = "${var.project}+${var.env}-unsized"
  }
}

resource "aws_s3_bucket" "imgproc_sized" {
    bucket = var.sized_img_bucket
    force_destroy = true

  tags = {
    Name = "${var.project}+${var.env}-sized"
  }
}


//Make the bucket publicly available
resource "aws_s3_bucket_public_access_block" "bucket" {
    bucket = aws_s3_bucket.imgproc_sized.id
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

locals {
  bucket_names = {
    unsized = var.unsized_img_bucket,
    sized = var.sized_img_bucket
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.imgproc_sized.id
  policy = templatefile("${path.module}/bucket_policy.json.tpl", local.bucket_names)
}

# resource "aws_s3_bucket_policy" "policy_two" {
#   bucket = aws_s3_bucket.imgproc_unsized.id
#   policy = templatefile("${path.module}/bucket_policy.json.tpl", local.bucket_names)
# }


//Bucket policy
# resource "aws_s3_bucket_policy" "bucket_policy" {
#     bucket = aws_s3_bucket.imgproc_sized.id
#     policy = jsonencode({
#          "Version": "2012-10-17",
#          "Statement": [
#             {
#                 "Sid": "Statement1",
#                 "Effect": "Allow",
#                 "Principal": "*",
#                 "Action": "s3:*",
#                 "Resource": [
#                     "arn:aws:s3:::${var.unsized_img_bucket}",
#                     "arn:aws:s3:::${var.sized_img_bucket}/*"
#                 ]
#             }
#         ]
#     })


#}
