locals {
  secrets = jsondecode(nonsensitive(data.sops_file.secrets.raw))
}
