/*
In this example, we first define the Lambda layer using the aws_lambda_layer_version resource. 
We specify the filename of the layer ZIP file, a layer_name to identify the layer,
and the compatible_runtimes for the layer.
Next, we define the Lambda function using the aws_lambda_function resource. 

We specify the function_name, role, handler, runtime, and filename for the function. We also attach 
the layer to the function by setting the layers property to an array containing the ARN of the layer.

We then define the IAM role for the Lambda function using the aws_iam_role resource. 
We specify a name for the role and an assume_role_policy to allow the Lambda service to assume the role.

To grant the Lambda function access to the layer, we define an IAM policy using the aws_iam_policy resource. 
We specify a name for the policy and a policy document that allows the lambda:GetLayerVersion action on the ARN 
of the layer. We then attach this policy to the role using the aws_iam_policy_attachment resource.
*/


# First, define the layer
resource "aws_lambda_layer_version" "example_layer" {
  filename   = "example_layer.zip"
  layer_name = "example_layer"
  
  # Specify the runtime the layer is compatible with
  compatible_runtimes = [
    "python3.8"
  ]
}

# Next, define the Lambda function
resource "aws_lambda_function" "example_lambda" {
  function_name = "example_lambda"
  role         = aws_iam_role.example_lambda_role.arn
  handler      = "example_lambda.handler"
  runtime      = "python3.8"
  filename     = "example_lambda.zip"

  # Attach the layer to the function
  layers = [aws_lambda_layer_version.example_layer.arn]
}

# Finally, define the IAM role for the Lambda function
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
}

# Attach a policy to the role granting access to the layer
resource "aws_iam_policy_attachment" "example_layer_policy" {
  policy_arn = aws_iam_policy.example_layer_policy.arn
  roles      = [aws_iam_role.example_lambda_role.name]
}

# Define the policy allowing access to the layer
resource "aws_iam_policy" "example_layer_policy" {
  name = "example_layer_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:GetLayerVersion"
        ]
        Resource = aws_lambda_layer_version.example_layer.arn
      }
    ]
  })
}