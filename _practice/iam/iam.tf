data "aws_caller_identity" "current" {}

# 역할 1.
resource "aws_iam_role" "admin_role" {
    name = "AdminRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                }
            }
        ]
    })
}

# 역할 2.
resource "aws_iam_role" "manager_role" {
    name = "ManagerRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "sts:AssumeRole"
                Principal = {
                    AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                }
            }
        ]
    })
}

# 역할 3. 인스턴스
resource "aws_iam_role" "instance1_role" {
  name = "Instance1Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "instance1_profile" {
  name = "Instance1Profile"
  role = aws_iam_role.instance1_role.name
}

# 정책 정의
resource "aws_iam_policy" "ec2_admin_policy" {
  name = "EC2AdminPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:*"
        Resource = "arn:aws:ec2:*:*:instance/instance1"
      },
      {
        Effect   = "Deny"
        Action   = "ec2:TerminateInstances"
        Resource = "arn:aws:ec2:*:*:instance/instance1"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_read_policy" {
    name = "CloudWatchReadPolicy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:Describe*",
                    "logs:Get*",
                    "logs:List*",
                    "logs:StartQuery",
                    "logs:StopQuery",
                    "logs:TestMetricFilter",
                    "logs:FilterLogEvents"
                ]
                Resource = "arn:aws:logs:*:*:log-group:group1:*"
            },
        ]
    })  
}

resource "aws_iam_policy" "cloudwatch_write_policy" {
    name = "CloudWatchWritePolicy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "arn:aws:logs:*:*:log-group:group1:*"
            },
        ]
    })
}

resource "aws_iam_policy" "s3_read_write_policy" {
    name = "S3ReadWritePolicy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                "s3:GetObject",
                "s3:PutObject"
                ]
                Resource = [
                    "arn:aws:s3:::bucket1/*"
                ]
            },
        ]
    })
}

resource "aws_iam_policy" "s3_list_get_policy" {
    name = "S3ListGetPolicy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:ListBucket"
                ]
                Resource = [
                    "arn:aws:s3:::bucket1",
                ]
            },
        ]
    })
}

# 사용자가 역할을 맡을 수 있는 정책 (수정 필요한 부분)
resource "aws_iam_user_policy" "user1_assume_role_policy" {
  name = "AllowAssumeAdminRole"
  user = "user1"  # 기존 사용자 이름
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.admin_role.arn
      }
    ]
  })
}

resource "aws_iam_user_policy" "user2_assume_role_policy" {
  name = "AllowAssumeManagerRole"
  user = "user2"  # 기존 사용자 이름
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.manager_role.arn
      }
    ]
  })
}

locals {
  role_policy_attachments = {
    "admin_role_policies" = {
      role_name = aws_iam_role.admin_role.name
      policies  = [aws_iam_policy.ec2_admin_policy.arn]
    }
    
    "manager_role_policies" = {
      role_name = aws_iam_role.manager_role.name
      policies  = [
        aws_iam_policy.cloudwatch_read_policy.arn,
        aws_iam_policy.s3_read_write_policy.arn,
        aws_iam_policy.s3_list_get_policy.arn
      ]
    }
    
    "instance1_role_policies" = {
      role_name = aws_iam_role.instance1_role.name
      policies  = [
        aws_iam_policy.cloudwatch_write_policy.arn,
        aws_iam_policy.s3_list_get_policy.arn
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "admin_ec2_policy" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.ec2_admin_policy.arn
}

resource "aws_iam_role_policy_attachment" "manager_cloudwatch_read" {
  role       = aws_iam_role.manager_role.name
  policy_arn = aws_iam_policy.cloudwatch_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "manager_s3_object_read_write" {
  role       = aws_iam_role.manager_role.name
  policy_arn = aws_iam_policy.s3_object_read_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "manager_s3_list" {
  role       = aws_iam_role.manager_role.name
  policy_arn = aws_iam_policy.s3_list_policy.arn
}

resource "aws_iam_role_policy_attachment" "instance1_cloudwatch_write" {
  role       = aws_iam_role.instance1_role.name
  policy_arn = aws_iam_policy.cloudwatch_write_policy.arn
}

resource "aws_iam_role_policy_attachment" "instance1_s3_list" {
  role       = aws_iam_role.instance1_role.name
  policy_arn = aws_iam_policy.s3_list_policy.arn
}

# resource "aws_iam_role_policy_attachment" "all_attachments" {
#   for_each = {
#     for pair in flatten([
#       for key, mapping in local.role_policy_attachments : [
#         for policy in mapping.policies : {
#           role    = mapping.role_name
#           policy  = policy
#           map_key = "${key}-${policy}"
#         }
#       ]
#     ]) : pair.map_key => pair
#   }
  
#   role       = each.value.role
#   policy_arn = each.value.policy
# }
