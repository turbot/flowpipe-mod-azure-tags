## v0.2.0 [2024-08-21]

_Enhancements_

- Added a default value for the `base_tag_rules` variable. ([#18](https://github.com/turbot/flowpipe-mod-azure-tags/pull/18))

## v0.1.0 [2024-07-24]

_What's new?_

- Detect and correct misconfigured tags across 55+ Azure resource types.
- Automatically add mandatory tags (e.g. `env`, `owner`).
- Clean up prohibited tags (e.g. `secret`, `key`).
- Reconcile shorthand or misspelled tag keys to standardized keys (e.g. `cc` to `cost_center`).
- Update tag values to conform to expected standards, ensuring consistency (e.g. `Prod` to `prod`).

For detailed usage information and a full list of pipelines, please see [Azure Tags Mod](https://hub.flowpipe.io/mods/turbot/azure_tags).

