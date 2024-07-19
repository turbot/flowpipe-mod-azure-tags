trigger "query" "detect_and_correct_data_lake_stores_with_incorrect_tags" {
  title       = "Detect & correct Data lake stores with incorrect tags"
  description = "Detects Data lake stores with incorrect tags and optionally attempts to correct them."
  tags        = local.data_lake_common_tags

  enabled  = var.data_lake_stores_with_incorrect_tags_trigger_enabled
  schedule = var.data_lake_stores_with_incorrect_tags_trigger_schedule
  database = var.database
  sql      = local.data_lake_stores_with_incorrect_tags_query

  capture "insert" {
    pipeline = pipeline.correct_resources_with_incorrect_tags
    args = {
      items = self.inserted_rows
    }
  }
}

pipeline "detect_and_correct_data_lake_stores_with_incorrect_tags" {
  title       = "Detect & correct Data lake stores with incorrect tags"
  description = "Detects Data lake stores with incorrect tags and optionally attempts to correct them."
  tags        = merge(local.data_lake_common_tags, {
    type = "featured"
  })

  param "database" {
    type        = string
    description = local.description_database
    default     = var.database
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

  step "query" "detect" {
    database = param.database
    sql      = local.data_lake_stores_with_incorrect_tags_query
  }

  step "pipeline" "correct" {
    pipeline = pipeline.correct_resources_with_incorrect_tags
    args = {
      items              = step.query.detect.rows
      notifier           = param.notifier
      notification_level = param.notification_level
      approvers          = param.approvers
      default_action     = param.default_action
    }
  }
}

variable "data_lake_stores_tag_rules" {
  type = object({
    add           = optional(map(string))
    remove        = optional(list(string))
    remove_except = optional(list(string))
    update_keys   = optional(map(list(string)))
    update_values = optional(map(map(list(string))))
  })
  description = "Resource specific tag rules"
  default     = null
}

variable "data_lake_stores_with_incorrect_tags_trigger_enabled" {
  type        = bool
  default     = false
  description = "If true, the trigger is enabled."
}

variable "data_lake_stores_with_incorrect_tags_trigger_schedule" {
  type        = string
  default     = "15m"
  description = "The schedule on which to run the trigger if enabled."
}

locals {
  data_lake_stores_tag_rules = {
    add           = merge(local.base_tag_rules.add, try(var.data_lake_stores_tag_rules.add, {})) 
    remove        = distinct(concat(local.base_tag_rules.remove , try(var.data_lake_stores_tag_rules.remove, [])))
    remove_except = distinct(concat(local.base_tag_rules.remove_except , try(var.data_lake_stores_tag_rules.remove_except, [])))
    update_keys   = merge(local.base_tag_rules.update_keys, try(var.data_lake_stores_tag_rules.update_keys, {}))
    update_values = merge(local.base_tag_rules.update_values, try(var.data_lake_stores_tag_rules.update_values, {}))
  }
}

locals {
  data_lake_stores_update_keys_override   = join("\n", flatten([for key, patterns in local.data_lake_stores_tag_rules.update_keys : [for pattern in patterns : format("      when key %s '%s' then '%s'", (length(split(":", pattern)) > 1 && contains(local.operators, element(split(":", pattern), 0)) ? element(split(":", pattern), 0) : "="), (length(split(":", pattern)) > 1 && contains(local.operators, element(split(":", pattern), 0)) ? join(":", slice(split(":", pattern), 1, length(split(":", pattern)))) : pattern), key)]]))
  data_lake_stores_remove_override        = join("\n", length(local.data_lake_stores_tag_rules.remove) == 0 ? ["      when new_key like '%' then false"] : [for pattern in local.data_lake_stores_tag_rules.remove : format("      when new_key %s '%s' then true", (length(split(":", pattern)) > 1 && contains(local.operators, element(split(":", pattern), 0)) ? element(split(":", pattern), 0) : "="), (length(split(":", pattern)) > 1 && contains(local.operators, element(split(":", pattern), 0)) ? join(":", slice(split(":", pattern), 1, length(split(":", pattern)))) : pattern))])
  data_lake_stores_remove_except_override = join("\n", length(local.data_lake_stores_tag_rules.remove_except) == 0 ? ["      when new_key like '%' then true"] : flatten([[for key in keys(merge(local.data_lake_stores_tag_rules.add, local.data_lake_stores_tag_rules.update_keys)) : format("      when new_key = '%s' then true", key)], [for pattern in local.data_lake_stores_tag_rules.remove_except : format("      when new_key %s '%s' then true", (length(split(":", pattern)) > 1 && contains(local.operators, element(split(":", pattern), 0)) ? element(split(":", pattern), 0) : "="), (length(split(":", pattern)) > 1 && contains(local.operators, element(split(":", pattern), 0)) ? join(":", slice(split(":", pattern), 1, length(split(":", pattern)))) : pattern))]]))
  data_lake_stores_add_override           = join(",\n", length(keys(local.data_lake_stores_tag_rules.add)) == 0 ? ["      (null, null)"] : [for key, value in local.data_lake_stores_tag_rules.add : format("      ('%s', '%s')", key, value)])
  data_lake_stores_update_values_override = join("\n", flatten([for key in sort(keys(local.data_lake_stores_tag_rules.update_values)) : [flatten([for new_value, patterns in local.data_lake_stores_tag_rules.update_values[key] : [contains(patterns, "else:") ? [] : [for pattern in patterns : format("      when new_key = '%s' and value %s '%s' then '%s'", key, (length(split(": ", pattern)) > 1 && contains(local.operators, element(split(": ", pattern), 0)) ? element(split(": ", pattern), 0) : "="), (length(split(": ", pattern)) > 1 && contains(local.operators, element(split(": ", pattern), 0)) ? join(": ", slice(split(": ", pattern), 1, length(split(": ", pattern)))) : pattern), new_value)]]]), contains(flatten([for p in values(local.data_lake_stores_tag_rules.update_values[key]) : p]), "else:") ? [format("      when new_key = '%s' then '%s'", key, [for new_value, patterns in local.data_lake_stores_tag_rules.update_values[key] : new_value if contains(patterns, "else:")][0])] : []]]))
}

locals {
  data_lake_stores_with_incorrect_tags_query = replace(
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                local.tags_query_template,
                "__TITLE__", "coalesce(name, title)"
              ),
              "__TABLE_NAME__", "azure_data_lake_store"
            ),
            "__UPDATE_KEYS_OVERRIDE__", local.data_lake_stores_update_keys_override
          ),
          "__REMOVE_OVERRIDE__", local.data_lake_stores_remove_override
        ),
        "__REMOVE_EXCEPT_OVERRIDE__", local.data_lake_stores_remove_except_override
      ),
      "__ADD_OVERRIDE__", local.data_lake_stores_add_override
    ),
    "__UPDATE_VALUES_OVERRIDE__", local.data_lake_stores_update_values_override
  )
}