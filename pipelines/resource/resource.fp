locals {
  resource_common_tags = merge(local.azure_tags_common_tags, {
    service = "Azure/Resource"
  })
}