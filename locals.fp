locals {
  azure_tags_common_tags = {
    category = "tags"
    plugin   = "azure"
    service  = "Azure"
  }
}

// Consts
locals {
  level_verbose = "verbose"
  level_info    = "info"
  level_error   = "error"
  style_ok      = "ok"
  style_info    = "info"
  style_alert   = "alert"
}

locals {
  notification_level_enum = ["info", "verbose", "error"]
}

// Common Texts
locals {
  description_database         = "Database connection string."
  description_approvers        = "List of notifiers to be used for obtaining action/approval decisions."
  description_connection       = "Name of the Azure connection to be used for any authenticated actions."
  description_max_concurrency  = "The maximum concurrency to use for responding to detection items."
  description_notifier         = "The name of the notifier to use for sending notification messages."
  description_notifier_level   = "The verbosity level of notification messages to send."
  description_default_action   = "The default action to use for the detected item, used if no input is provided."
  description_enabled_actions  = "The list of enabled actions to provide to approvers for selection."
  description_trigger_enabled  = "If true, the trigger is enabled."
  description_trigger_schedule = "The schedule on which to run the trigger if enabled."
  description_items            = "A collection of detected resources to run corrective actions against."
}

// Default action enum

locals {
  incorrect_tags_default_action_enum = ["notify", "skil", "apply"]
}

locals {
  base_tag_rules = {
    add           = try(var.base_tag_rules.add, {})
    remove        = try(var.base_tag_rules.remove, [])
    remove_except = try(var.base_tag_rules.remove_except, [])
    update_keys   = try(var.base_tag_rules.update_keys, {})
    update_values = try(var.base_tag_rules.update_values, {})
  }
}

locals {
  operators = ["~", "~*", "like", "ilike", "="]

  tags_query_template = <<-EOQ
with tags as (
  select
    __TITLE__ as title,
    id,
    region,
    subscription_id,
    sp_connection_name as conn,
    coalesce(tags, '{}'::jsonb) as tags,
    t.key,
    t.value
  from
    __TABLE_NAME__
  left join
    jsonb_each_text(tags) as t(key, value) on true
),
updated_tags as (
  select
    id,
    key as old_key,
    case
      when false then key
__UPDATE_KEYS_OVERRIDE__
      else key
    end as new_key,
    value
  from
    tags
  where key is not null
),
required_tags as (
  select
    r.id,
    null as old_key,
    a.key as new_key,
    a.value
  from
    (select distinct id from __TABLE_NAME__) r
  cross join (
    values
__ADD_OVERRIDE__
  ) as a(key, value)
  where not exists (
    select 1 from updated_tags ut where ut.id = r.id and ut.new_key = a.key
  )
),
all_tags as (
  select id, old_key, new_key, value from updated_tags
  union all
  select id, old_key, new_key, value from required_tags where new_key is not null
),
allowed_tags as (
  select distinct
    id,
    new_key
  from (
    select
      id,
      new_key,
      case
__REMOVE_EXCEPT_OVERRIDE__
        else false
      end as allowed
    from all_tags
  ) a
  where allowed = true
),
remove_tags as (
  select distinct id, key from (
    select
      id,
      new_key as key,
      case
__REMOVE_OVERRIDE__
        else false
      end   as remove
    from all_tags) r
    where remove = true
  union
  select id, new_key as key from all_tags a where not exists (select 1 from allowed_tags at where at.id = a.id and at.new_key = a.new_key)
),
updated_values as (
  select
    id,
    new_key,
    value as old_value,
    case
      when false then value
__UPDATE_VALUES_OVERRIDE__
      else value
    end as updated_value
  from
    all_tags
)
select * from (
  select
    t.title,
    t.id,
    t.region,
    t.subscription_id,
    t.conn,
    t.tags as old_tags,
    jsonb_object_agg(uv.new_key, uv.updated_value) as new_tags
  from
    tags t
  join
    updated_values uv on t.id = uv.id
  where
    not exists (
      select 1 from remove_tags rt where rt.id = uv.id and rt.key = uv.new_key
    )
  group by
    t.title, t.id, t.region, t.subscription_id, t.conn, t.tags
) result
where old_tags != new_tags;
  EOQ
}
