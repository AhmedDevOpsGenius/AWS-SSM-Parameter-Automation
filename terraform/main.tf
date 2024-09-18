provider "aws" {
  region = "us-west-1"
}

locals {
  parameters = jsondecode(file("${path.module}/parameters.json"))
}

# Restructure parameters to provide a valid map for for_each
locals {
  structured_params = flatten([
    for parent, repos in local.parameters : [
      for repo, params in repos : [
        for param in params : {
          name  = "/${parent}/${repo}/${param.Name}"
          value = param.Value
          type  = param.Type
        }
      ]
    ]
  ])

  # Create a map for for_each by indexing the list
  params_map = { for idx, param in local.structured_params : idx => param }
}

# Function to convert unsupported types to allowed SSM types
locals {
  converted_params = {
    for idx, param in local.params_map : idx => {
      name  = param.name
      value = param.value
      type  = (
        contains(["String", "StringList", "SecureString"], param.type) ? param.type : "String"
      )
    }
  }
}

resource "aws_ssm_parameter" "ssm_params" {
  for_each = local.converted_params

  name  = each.value["name"]
  value = each.value["value"]
  type  = each.value["type"]

  tags = {
    created_by = "terraform"
  }
}
