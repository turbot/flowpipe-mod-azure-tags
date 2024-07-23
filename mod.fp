mod "azure_tags" {
  title         = "Azure Tags"
  description   = "Run pipelines to detect and correct Azure tags that violate your provided ruleset."
  color         = "#0089D6"
  documentation = file("./README.md")
  icon          = "/images/mods/turbot/azure-tags.svg"
  categories    = ["azure", "tags", "public cloud"]
  opengraph {
    title       = "Azure Tags Mod for Flowpipe"
    description = "Run pipelines to detect and correct Azure tags that violate your provided ruleset."
    image       = "/images/mods/turbot/azure-tags-social-graphic.png"
  }
  require {
    mod "github.com/turbot/flowpipe-mod-detect-correct" {
      version = "*"
    }
    mod "github.com/turbot/flowpipe-mod-azure" {
      version = "v0.2.0-rc.3"
    }
  }
}