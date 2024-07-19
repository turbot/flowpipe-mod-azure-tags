locals {
  batch_account_common_tags = merge(local.azure_tags_common_tags, {
    service = "Azure/BatchAccount"
  })
}