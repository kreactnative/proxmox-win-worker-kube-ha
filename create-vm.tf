terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.38.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.PROXMOX_API_ENDPOINT
  username = "${var.PROXMOX_USERNAME}@pam"
  password = var.PROXMOX_PASSWORD
  insecure = true
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "mkdir -p output && rm -f join-worker.sh"
    working_dir = path.root
  }
}

module "master_domain" {
  source             = "./modules/linux"
  count              = var.MASTER_COUNT
  name               = format("terraform-master-%s", count.index + 1)
  memory             = var.master_config.memory
  vcpus              = var.master_config.vcpus
  sockets            = var.master_config.sockets
  autostart          = var.autostart
  default_bridge     = var.DEFAULT_BRIDGE
  target_node        = var.TARGET_NODE
  ssh_key            = var.ssh_key
  user               = var.user
  linux_template_id  = var.linux_template_id
  linux_storage_name = var.linux_storage_name
}

module "worker_domain" {
  source             = "./modules/linux"
  count              = var.WORKER_COUNT
  name               = format("terraform-worker-%s", count.index + 1)
  memory             = var.worker_config.memory
  vcpus              = var.worker_config.vcpus
  sockets            = var.worker_config.sockets
  autostart          = var.autostart
  default_bridge     = var.DEFAULT_BRIDGE
  target_node        = var.TARGET_NODE
  ssh_key            = var.ssh_key
  user               = var.user
  linux_template_id  = var.linux_template_id
  linux_storage_name = var.linux_storage_name
}
