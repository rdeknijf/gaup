data "cloudflare_zones" "deknijf-com" {
  filter {
    name = "deknijf.com"
  }
}