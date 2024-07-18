locals {
  app_ervice_common_tags = merge(local.azure_tags_common_tags, {
    service = "Azure/AppService"
  })
}