resource "google_storage_bucket" "main" {
  name     = "deknijf-gaup"
  location = "EUROPE-WEST4"
  website {
    main_page_suffix = "index.html"
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "public" {
  bucket = google_storage_bucket.main.name
  role = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "main" {
  name        = "gaup"
  bucket_name = google_storage_bucket.main.name
  enable_cdn  = false
}

resource "google_compute_url_map" "main" {
  name            = "gaup"
  default_service = google_compute_backend_bucket.main.self_link
}

resource "google_compute_managed_ssl_certificate" "main" {
  name = "gaup"
  managed {
    domains = [
      "gaup.deknijf.com"
    ]
  }
}

resource "google_compute_target_https_proxy" "main" {
  name             = "gaup"
  url_map          = google_compute_url_map.main.self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.main.self_link]
}

resource "google_compute_global_address" "main" {
  name         = "gaup"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "cdn_global_forwarding_rule" {
  name       = "gaup"
  target     = google_compute_target_https_proxy.main.self_link
  ip_address = google_compute_global_address.main.address
  port_range = "443"
}

resource "cloudflare_record" "main" {
  zone_id = lookup(data.cloudflare_zones.deknijf-com.zones[0], "id")
  name    = "gaup"
  value   = google_compute_global_address.main.address
  type    = "A"
  ttl     = 3600
}

# http-to-https redirect

resource "google_compute_url_map" "http-redirect" {
  name = "gaup-http-redirect"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

resource "google_compute_target_http_proxy" "http-redirect" {
  name    = "gaup-http-redirect"
  url_map = google_compute_url_map.http-redirect.self_link
}

resource "google_compute_global_forwarding_rule" "http-redirect" {
  name       = "gaup-http-redirect"
  target     = google_compute_target_http_proxy.http-redirect.self_link
  ip_address = google_compute_global_address.main.address
  port_range = "80"
}