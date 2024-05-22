{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "{{.Sid }}",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::{%.unsized %}",
        "arn:aws:s3:::{%.sized %}"
      ]
    }
  ]
}