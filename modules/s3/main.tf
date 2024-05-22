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

resource "aws_s3_bucket_public_access_block" "unsized_bucket" {
    bucket = aws_s3_bucket.imgproc_unsized.id
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

//Bucket policy
 resource "aws_s3_bucket_policy" "sized_bucket_policy" {
     bucket = aws_s3_bucket.imgproc_sized.id
     policy = jsonencode({
          "Version": "2012-10-17",
          "Statement": [
             {
                 "Sid": "Statement1",
                 "Effect": "Allow",
                 "Principal": "*",
                 "Action": "s3:*",
                 "Resource": [
                     "arn:aws:s3:::${var.sized_img_bucket}"
                 ]
             }
         ]
     })
}

 resource "aws_s3_bucket_policy" "unsized_bucket_policy" {
     bucket = aws_s3_bucket.imgproc_unsized.id
     policy = jsonencode({
          "Version": "2012-10-17",
          "Statement": [
             {
                 "Sid": "Statement1",
                 "Effect": "Allow",
                 "Principal": "*",
                 "Action": "s3:*",
                 "Resource": [
                     "arn:aws:s3:::${var.unsized_img_bucket}"
                 ]
             }
         ]
     })
}