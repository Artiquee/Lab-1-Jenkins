terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure AWS provider and creds
provider "aws" {
  region                   = "us-east-1"
}

# Creating bucket
resource "aws_s3_bucket" "website" {
  bucket = "lab2-terraform-imim23"

  tags = {
    Name        = "Website"
    Environment = "Dev"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls   = false
  block_public_policy = false
  restrict_public_buckets = false
  ignore_public_acls = true
}

data "aws_iam_policy_document" "website_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website_read.json
}

resource "aws_s3_bucket_object" "indexfile" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "./src/index.html"
#  acl          = "public-read"
  content_type = "text/html"
}

output "website_endpoint" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}
