#
# This terraform plan defines the resources necessary for DNS setup of jenkins.io
#

locals {
  a_records = {
    # Root
    "" = "40.79.70.97"

    # Physical machine at Contegix
    cucumber = "199.193.196.24"

    # VM at Rackspace
    celery = "162.242.234.101"
    okra = "162.209.106.32"

    # cabbage has died of dysentery
    cabbage = "104.130.167.56"
    kelp = "162.209.124.149"

    # Hosts at OSUOSL
    lettuce = "140.211.9.32"

    # artichoke has died of dysentery
    artichoke = "140.211.9.22"
    eggplant = "140.211.15.101"
    edamame = "140.211.9.2"
    radish = "140.211.9.94"

    # EC2
    rating = "52.23.130.110"
    mirrors = "52.202.51.185"
    ci = "52.71.231.250"
    l10n = "52.71.7.244"
    census = "52.202.38.86"
    usage = "52.204.62.78"

    # Azure
    ldap = "52.232.180.203"
  }

  aaaa_records = {
    # VM at Rackspace
    celery = "2001:4802:7801:103:be76:4eff:fe20:357c"
    okra = "2001:4802:7800:2:be76:4eff:fe20:7a31"
  }
  
  cname_records = {
    # Azure
    accounts = "nginx.azure"
    nginx.azure = "jenkins.io"
    javadoc = "nginx.azure"
    plugins = "nginx.azure"
    repo.azure = "nginx.azure"
    updates.azure = "nginx.azure"
    reports = "nginx.azure"
    www = "nginx.azure"
    evergreen = "nginx.azure"
    uplink = "nginx.azure"

    # CNAME Records
    pkg = "mirrors"
    puppet = "raddish"
    updates = "mirrors"
    archives = "okra"
    stats = "jenkins-infra.github.io"
    patron = "jenkins-infra.github.io"
    wiki = "lettuce"
    issues = "edamame"

    # Magical CNAME for certificate validation
    D07F852F584FA592123140354D366066.ldap.jenkins.io. = "75E741181A7ACDBE2996804B2813E09B65970718.comodoca.com."

    # Amazon SES configuration to send out email from noreply@jenkins.io
    pbssnl2yyudgfdl3flznotnarnamz5su._domainkey = "pbssnl2yyudgfdl3flznotnarnamz5su.dkim.amazonses.com."
    "6ch6fw67efpfgoqyhdhs2cy2fpkwrvsk._domainkey" = "6ch6fw67efpfgoqyhdhs2cy2fpkwrvsk.dkim.amazonses.com."
    "37qo4cqmkxeocwr2iicjop77fq52m6yh._domainkey" = "37qo4cqmkxeocwr2iicjop77fq52m6yh.dkim.amazonses.com."

    # Others
    _26F1803EE76B9FFE3884B762F77A11B5.ldap.jenkins.io. = "BB7DE2B47B0E47A15260A401C6A5477E.F6289F84FFAA8F222EE876DEE5D91C0C.5ac644adc424f.comodoca.com."
  }

  txt_records = {
    # Amazon SES configuration to send out email from noreply@jenkins.io    
    _amazonses = "kYNeW+b+9GnKO/LzqP/t0TzLyN86jQ9didoBAJSjezE="
    # mailgun configuration
    "" = "v=spf1 include:mailgun.org ~all"
    mailo._domainkey = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCpS+8K+bVvFlfTqbVbuvM9SoX0BqjW3zK7BJeCZ4GnaJTeRaurKx81hUX1wz3wKt+Qt9xI+X6mAlar2Co+B13GsNZIlYVdO/zBVtZG+R5KvMQUynNyie05oRyaTFWtNEiQVgGYgM4xkwlIWSA9EXmBMaKg7ze3kKNKUOnzKDIxMQIDAQAB"
  }
}

resource "azurerm_resource_group" "jenkinsio_dns" {
  name     = "${var.prefix}jenkinsio_dns"
  location = "${var.location}"
  tags {
      env = "${var.prefix}"
  }
}

resource "azurerm_dns_zone" "jenkinsio" {
  name                = "jenkins.io"
  resource_group_name = "${azurerm_resource_group.jenkinsio_dns.name}"
}

resource "azurerm_dns_a_record" "a_entries" {
  count               = "${length(local.a_records)}"
  name                = "${element(keys(local.a_records), count.index)}"
  zone_name           = "${azurerm_dns_zone.jenkinsio.name}"
  resource_group_name = "${azurerm_resource_group.jenkinsio_dns.name}"
  ttl                 = 3600
  records             = ["${local.a_records[element(keys(local.a_records), count.index)]}"]
}

resource "azurerm_dns_aaaa_record" "aaaa_entries" {
  count               = "${length(local.aaaa_records)}"
  name                = "${element(keys(local.aaaa_records), count.index)}"
  zone_name           = "${azurerm_dns_zone.jenkinsio.name}"
  resource_group_name = "${azurerm_resource_group.jenkinsio_dns.name}"
  ttl                 = 3600
  records             = ["${local.aaaa_records[element(keys(local.aaaa_records), count.index)]}"]
}

resource "azurerm_dns_cname_record" "cname_entries" {
  count               = "${length(local.cname_records)}"
  name                = "${element(keys(local.cname_records), count.index)}"
  zone_name           = "${azurerm_dns_zone.jenkinsio.name}"
  resource_group_name = "${azurerm_resource_group.jenkinsio_dns.name}"
  ttl                 = 3600
  record             = "${local.cname_records[element(keys(local.cname_records), count.index)]}"
}

resource "azurerm_dns_txt_record" "txt_entries" {
  count               = "${length(local.txt_records)}"
  name                = "${element(keys(local.txt_records), count.index)}"
  zone_name           = "${azurerm_dns_zone.jenkinsio.name}"
  resource_group_name = "${azurerm_resource_group.jenkinsio_dns.name}"
  ttl                 = 3600
  record {
    value = "${local.txt_records[element(keys(local.txt_records), count.index)]}"
  }
}

resource "azurerm_dns_ns_record" "ns_entries" {
  name                = ""
  zone_name           = "${azurerm_dns_zone.jenkinsio.name}"
  resource_group_name = "${azurerm_resource_group.jenkinsio_dns.name}"
  ttl                 = 3600
  records             = ["ns1.jenkins-ci.org.", "ns2.jenkins-ci.org.", "ns3.jenkins-ci.org."]
}

resource "azurerm_dns_mx_record" "mx_entries" {
  name                = "spamtrap"
  zone_name           = "${azurerm_dns_zone.jenkinsio.name}"
  resource_group_name = "${azurerm_resource_group.jenkinsio_dns.name}"
  ttl                 = 3600

  record {
    preference = 10
    exchange   = "mxa.mailgun.org."
  }

  record {
    preference = 10
    exchange   = "mxb.mailgun.org."
  }
}