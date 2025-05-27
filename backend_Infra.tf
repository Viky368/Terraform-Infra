# locals {
#   env="dev"
# }

# resource "aws_s3_bucket" "tf_state" {
#   bucket = "${local.env}-optum-eks-terraform-state"

#   tags = {
#     "Name" = "${local.env}_TerraformStateBucket"
#   }
# }

# resource "aws_dynamodb_table" "tf_lock" {
#   name         = "${local.env}-terraform-lock-table"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags = {
#     "Name" = "${local.env}_TerraformLockTable"
#   }
# }

