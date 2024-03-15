resource "aws_api_gateway_rest_api" "api" {
  name = "serverless-api"
}

resource "aws_api_gateway_resource" "resource" {
  count       = length((var.object))
  path_part   = var.object[count.index].resourceName
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_method" "method" {
  count            = length((var.object))
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.resource[count.index].id
  http_method      = var.object[count.index].methodName
  authorization    = "NONE"
  api_key_required = true
}

# Every method request must add an integration request. It must be added.
resource "aws_api_gateway_integration" "integration" {
  count                   = length((var.object))
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource[count.index].id
  http_method             = aws_api_gateway_method.method[count.index].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda-function.invoke_arn
}