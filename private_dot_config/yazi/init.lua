require("git"):setup()

require("fr"):setup({
  rg = "--hidden --no-ignore",
})

require("fg"):setup({
  default_action = "jump", -- jump to file in yazi instead of opening menu
})
require("sshfs"):setup({
  mount_dir = os.getenv("HOME") .. "/mnt",
  sshfs_options = {
    "compression=yes",
    "ServerAliveInterval=15",
    "ServerAliveCountMax=3",
    "ConnectTimeout=5", -- fail fast instead of hanging
    "dir_cache=yes",
    "dcache_timeout=300",
    "dcache_max_size=10000",
    "cache_timeout=300",
    "cache_stat_timeout=300",
    "cache_dir_timeout=300",
    "cache_link_timeout=300",
  },
})

require("bunny"):setup({
  hops = {
    { key = ";", path = "~", desc = "$HOME" },
    { key = "/", path = "/", desc = "/" },
    { key = "t", path = "/tmp", desc = "/tmp" },
    { key = "l", path = "~/.local", desc = ".local" },
    { key = "o", path = os.getenv("OMARCHY_PATH"), desc = "omarchy" },
    { key = "c", path = "~/.config", desc = ".config" },
  },
  desc_strategy = "path",
  ephemeral = true,
  tabs = true,
  notify = false,
  fuzzy_cmd = "fzy",
})
