locals {
  iothub_common_tags = merge(local.azure_tags_common_tags, {
    service = "Azure/IoTHub"
  })
}