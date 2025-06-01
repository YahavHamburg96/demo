resource "aws_ecr_repository" "this" {
  for_each             = var.ecr_repositories
  name                 = "${each.key}"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true
}

# resource "aws_ecr_repository_policy" "this" {
#   repository = aws_ecr_repository.this.name

# policy = jsonencode({
#   Version = "2012-10-17"
#   Statement = [
#     {
#       Sid = "AllowRepoAdmin"
#       Effect = "Allow"
#       Principal = "*"
#       Action = "ecr:*"
#       Resource = "*"
#       Condition = {
#         StringEquals = {
#           "aws:PrincipalAccount" = var.aws_account_id
#         }
#       }
#     },
#     {
#       Effect = "Deny"
#       Principal = "*"
#       Action = "*"
#       Condition = {
#         StringNotEquals = {
#           "aws:sourceVpc" = var.aws_vpc_id
#         }
#       }
#     }
#   ]
# })

#}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.aws_vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id        = var.aws_vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.private_subnet_ids
}