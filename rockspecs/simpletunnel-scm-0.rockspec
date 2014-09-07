package = "simpletunnel"
version = "scm-0"
source = {
   url = "git://github.com/Vger/simpletunnel.git",
}
description = {
   summary = "Access to tuntap interfaces via ZeroMQ.",
   homepage = "https://github.com/Vger/simpletunnel",
   license = "MIT/X11",
}
dependencies = {
   "lua >= 5.1",
   "zmq-copas",
   "lua-tuntap",
}

build = {
  type = "none",
  install = {
    bin = {
      ["simpletunnel.lua"] = "src/simpletunnel.lua",
    },
  },
}
