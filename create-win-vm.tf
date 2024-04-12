module "win_worker_domain" {
  source             = "./modules/win"
  count              = var.WIN_WORKER_COUNT
  name               = format("w2022-worker-0%s", count.index + 1)
  memory             = var.win_worker_config.memory
  vcpus              = var.win_worker_config.vcpus
  sockets            = var.win_worker_config.sockets
  autostart          = var.autostart
  default_bridge     = var.DEFAULT_BRIDGE
  target_node        = var.TARGET_NODE
  ssh_key            = var.ssh_key
  user               = var.user
  template_id  = var.win_linux_template_id
  storage_name = var.win_linux_storage_name
}
