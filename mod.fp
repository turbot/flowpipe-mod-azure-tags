mod "azure_tags" {
  title         = "Azure Tags"
  description   = "Run pipelines to detect and correct Azure tags which are missing, prohibited or otherwise unexpected."
  color         = "#0089D6"
  documentation = file("./README.md")
  icon          = "/images/mods/turbot/azure-tags.svg"
  categories    = ["azure", "public cloud", "standard", "tags"]

  opengraph {
    title       = "Azure Tags Mod for Flowpipe"
    description = "Run pipelines to detect and correct Azure tags which are missing, prohibited or otherwise unexpected."
    image       = "/images/mods/turbot/azure-tags-social-graphic.png"
  }

  require {
    flowpipe {
      min_version = "1.0.0"
    }
    mod "github.com/turbot/flowpipe-mod-detect-correct" {
      version = "1.0.0-rc.0"
    }
    mod "github.com/turbot/flowpipe-mod-azure" {
      version = "v1.0.0-rc.1"
    }
  }
}
