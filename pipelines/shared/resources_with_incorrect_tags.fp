pipeline "correct_resources_with_incorrect_tags" {
  title       = "Correct resources with incorrect tags"
  description = "Correct resources with incorrect tags"

  param "items" {
    type = list(object({
      title           = string
      id              = string
      region          = string
      subscription_id = string
      cred            = string
      old_tags        = map(string)
      new_tags        = map(string)
    }))
    description = local.description_items
  }

  param "notifier" {
    type        = string
    description = local.description_notifier
    default     = var.notifier
  }

  param "notification_level" {
    type        = string
    description = local.description_notifier_level
    default     = var.notification_level
  }

  param "approvers" {
    type        = list(string)
    description = local.description_approvers
    default     = var.approvers
  }

  param "default_action" {
    type        = string
    description = local.description_default_action
    default     = var.incorrect_tags_default_action
  }

  step "pipeline" "correct_one" {
    for_each        = { for item in param.items : item.id => item }
    max_concurrency = var.max_concurrency
    pipeline        = pipeline.correct_one_resource_with_incorrect_tags
    args = {
      title              = each.value.title
      id                 = each.value.id
      region             = each.value.region
      subscription_id    = each.value.subscription_id
      cred               = each.value.cred
      old_tags           = each.value.old_tags
      new_tags           = each.value.new_tags
      notifier           = param.notifier
      notification_level = param.notification_level
      approvers          = param.approvers
      default_action     = param.default_action
    }
  }
}

pipeline "correct_one_resource_with_incorrect_tags" {
  title       = "Correct one resource with incorrect tags"
  description = "Correct one resource with incorrect tags"

  param "title" {
    type        = string
    description = "Title of the resource"
  }

  param "id" {
    type        = string
    description = "ID of the resource"
  }

  param "region" {
    type        = string
    description = "The region the resource is located in"
  }

  param "subscription_id" {
    type        = string
    description = "ID of the subscription containing the resource"
  }

  param "cred" {
    type        = string
    description = "Credential identifier"
  }

  param "old_tags" {
    type        = map(string)
    description = "Map of tags prior to correction"
  }

  param "new_tags" {
    type        = map(string)
    description = "Map of tags the correction should result in" 
  }

  param "notifier" {
    type        = string
    description = local.description_notifier
    default     = var.notifier
  }

  param "notification_level" {
    type        = string
    description = local.description_notifier_level
    default     = var.notification_level
  }

  param "approvers" {
    type        = list(string)
    description = local.description_approvers
    default     = var.approvers
  }

  param "default_action" {
    type        = string
    description = local.description_default_action
    default     = var.incorrect_tags_default_action
  }

  step "transform" "display_name" {
    value = format("%s (%s/%s)", param.title, param.subscription_id, param.region)
  }

  step "transform" "display_old_tags" {
    value = length(param.old_tags) > 0 ? format(" Existing tags: %s", join(", ", [for key, value in param.old_tags : format("%s=%s", key, value)])) : ""
  }

  step "transform" "display_new_tags" {
    value = length(param.new_tags) > 0 ? format(" New tags: %s", join(", ", [for key, value in param.new_tags : format("%s=%s", key, value)])) : ""
  }

  step "pipeline" "correction" {
    pipeline = detect_correct.pipeline.correction_handler
    args = {
      notifier           = param.notifier
      notification_level = param.notification_level
      approvers          = param.approvers
      detect_msg         = format("Detected %s with incorrect tags.%s%s", step.transform.display_name.value, step.transform.display_old_tags.value, step.transform.display_new_tags.value)
      default_action     = param.default_action
      enabled_actions    = ["skip", "apply"]
      actions = {
        "skip" = {
          label        = "Skip"
          value        = "skip"
          style        = local.style_info
          pipeline_ref = local.pipeline_optional_message
          pipeline_args = {
            notifier = param.notifier
            send     = param.notification_level == local.level_verbose
            text     = format("Skipped %s with incorrect tags.", step.transform.display_name.value)
          }
          success_msg = ""
          error_msg   = ""
        }
       "apply" = {
          label        = "Apply"
          value        = "apply"
          style        = local.style_ok
          pipeline_ref = local.pipeline_azure_tag_resource
          pipeline_args = {
            cred        = param.cred
            resource_id = param.id
            tags        = param.new_tags
            incremental = false
          }
          success_msg = "Applied changes to tags on ${param.title}."
          error_msg   = "Error applying changes to tags on ${param.title}."
        }
      }
    }
  }
}