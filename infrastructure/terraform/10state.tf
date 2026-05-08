terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.71.0"
    }
  }

  #
  # 1. Erste Ausführung (Backend auskommentiert): Erstellt S3-Bucket und DynamoDB-Tabelle
  # 2. Backend aktivieren: Auskommentierung entfernen und terraform init -migrate-state ausführen
  # 2. Bucket-Name anpassen: Der Bucket-Name dem echten Namen anpassen. Hier mit Zufasllswert im ersten Teil
  backend "s3" {
    bucket         = "terraform-state-pond-two-76045495"
    key            = "pond/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform_state_lock"
    encrypt        = true
    profile        = "tefde-sandbox"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "tefde-sandbox"
}

provider "random" {}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-state-pond-two-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "state_lock_table" {
  name         = "terraform_state_lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


