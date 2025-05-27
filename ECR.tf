resource "aws_ecr_repository" "my_ecr_repo" {
  name = "${local.env}/testapi"
  
  # Optionally add policies or other configurations
  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Env = "${local.env}"
  }
}