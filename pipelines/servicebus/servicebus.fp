# In the Azure portal, it is called "Service Bus".
# In the plugin, we have named it "servicebus".
locals {
  servicebus_common_tags = merge(local.azure_tags_common_tags, {
    service = "Azure/ServiceBus"
  })
}