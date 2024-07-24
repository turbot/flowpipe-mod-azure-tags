mod "azure_tags" {
  title         = "Azure Tags"
  description   = "Run pipelines to detect and correct Azure tags which are missing, prohibited or otherwise unexpected."
  color         = "#0089D6"
  documentation = file("./README.md")
  icon          = "/images/mods/turbot/azure-tags.svg"
  categories    = ["azure", "tags", "public cloud"]
  opengraph {
    title       = "Azure Tags Mod for Flowpipe"
    description = "Run pipelines to detect and correct Azure tags which are missing, prohibited or otherwise unexpected."
    image       = "/images/mods/turbot/azure-tags-social-graphic.png"
  }
  require {
    mod "github.com/turbot/flowpipe-mod-detect-correct" {
      version = "*"
    }
    mod "github.com/turbot/flowpipe-mod-azure" {
      version = "*"
    }
  }
}