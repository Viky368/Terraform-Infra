terraform {
 backend "s3" {
   bucket         = "local-optum-eks-terraform-state"
   key            = "EKS/local/terraform.tfstate"
   region         = "us-east-1"
   dynamodb_table = "local-terraform-lock-table"
 }
}
