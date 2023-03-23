# Define the Secret Manager
resource "aws_secretsmanager_secret" "example_secret" {
  name = "example_secret"
}

# Create a secret string for the Secret Manager
resource "aws_secretsmanager_secret_version" "example_secret_version" {
  secret_id     = aws_secretsmanager_secret.example_secret.id
  secret_string = jsonencode({
    username = "example_user"
    password = "example_password"
  })
}

# Define the Lambda function
resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda"
  role         = aws_iam_role.example_lambda_role.arn
  handler      = "example_lambda.handler"
  runtime      = "python3.8"
  filename     = "example_lambda.zip"

  # Attach the Secret Manager to the function
  environment {
    variables = {
      secret_username = aws_secretsmanager_secret_version.example_secret_version.secret_string.username
      secret_password = aws_secretsmanager_secret_version.example_secret_version.secret_string.password
    }
  }
}

# Define the IAM role for the Lambda function
resource "aws_iam_role" "example_lambda_role" {
  name = "example_lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  # Allow the role to access the Secret Manager
  inline_policy {
    name = "example_lambda_secret_access_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = aws_secretsmanager_secret.example_secret.arn
        }
      ]
    })
  }
}



/*
In this example, we first define the Secret Manager using the aws_secretsmanager_secret resource.
We specify a name for the secret.

Next, we create a secret string for the Secret Manager using the aws_secretsmanager_secret_version resource.
We specify the secret_id to associate the secret string with the previously
defined Secret Manager, and we set the secret_string to a JSON-encoded object containing a username and password.

We then define the Lambda function using the aws_lambda_function resource.
We specify the function_name, role, handler, runtime, and filename for the function.
We also attach the Secret Manager to the function by setting the environment
property to an object containing the variables property, which is set to an object containing
the secret_username and secret_password environment variables that reference
the username and password fields of the Secret Manager.

We then define the IAM role for the Lambda function using the aws_iam_role resource.
We specify a name for the role and an assume_role_policy to allow the Lambda service
to assume the role. We also define an inline policy to allow the role to access
the Secret Manager using the aws_iam_role.inline_policy block. We specify a name
for the policy and set the policy property to a JSON-encoded object containing a
Statement array that allows the secretsmanager:GetSecretValue action on the ARN of the Secret Manager

*/