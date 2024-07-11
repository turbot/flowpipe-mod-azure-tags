// trigger "query" "detect_and_correct_network_security_groups_with_incorrect_tags" {
//   title       = "Detect & correct Network Security Groups with incorrect tags"
//   description = "Detects Network Security Groups with incorrect tags and optionally attempts to correct them."
//   tags        = local.network_common_tags

//   enabled  = var.network_security_groups_with_incorrect_tags_trigger_enabled
//   schedule = var.network_security_groups_with_incorrect_tags_trigger_schedule
//   database = var.database
//   sql      = local.network_security_groups_with_incorrect_tags_query

//   capture "insert" {
//     pipeline = pipeline.correct_resources_with_incorrect_tags
//     args = {
//       items = self.inserted_rows
//     }
//   }
// }

// pipeline "detect_and_correct_network_security_groups_with_incorrect_tags" {
//   title       = "Detect & correct Network Security Groups with incorrect tags"
//   description = "Detects Network Security Groups with incorrect tags and optionally attempts to correct them."
//   tags        = merge(local.network_common_tags, {
//     type = "featured"
//   })

//   param "database" {
//     type        = string
//     description = local.description_database
//     default     = var.database
//   }

//   param "notifier" {
//     type        = string
//     description = local.description_notifier
//     default     = var.notifier
//   }

//   param "notification_level" {
//     type        = string
//     description = local.description_notifier_level
//     default     = var.notification_level
//   }

//   param "approvers" {
//     type        = list(string)
//     description = local.description_approvers
//     default     = var.approvers
//   }

//   param "default_action" {
//     type        = string
//     description = local.description_default_action
//     default     = var.incorrect_tags_default_action
//   }
// }