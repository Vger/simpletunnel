--[[
ZeroMQ access to TUN/TAP interface

Arguments to tunendpoint.lua:
  <device-name of tun/tap> <zmq publish address> <zmq pull address>

e.g.
  "/dev/tap0" "tcp://127.0.0.1:6000" "tcp://127.0.0.1:6001"
  will read frames from tap0 interface and publish frames
  on zeromq socket bound to 127.0.0.1:6000, and read frames
  from zeromq socket bound to 127.0.0.1:6001 and write them
  to tap0 interface.
--]]

local tuntap = require "tuntap"
local zmq = require "zmq"
local zmqcopas = require "zmq.copas"
local copas = require "copas"

local zmqctx

local DEFAULT_IFACE_PATH = "/dev/tap0"
local DEFAULT_PUB_ADDR = "tcp://127.0.0.1:5550"
local DEFAULT_PULL_ADDR = "tcp://127.0.0.1:5551"

local function retriever(tunnel, pull)
    return function()
	while true do
	    local outgoing = pull:receive(1)
	    copas.send(tunnel, outgoing)
	end
    end
end

local function publisher(tunnel, pub)
    return function()
	while true do
	    local incoming = copas.receive(tunnel)
	    pub:send(incoming)
	end
    end
end

local function init(iface_path, pub_addr, pull_addr)
    iface_path = iface_path or DEFAULT_IFACE_PATH
    pub_addr = pub_addr or DEFAULT_PUB_ADDR
    pull_addr = pull_addr or DEFAULT_PULL_ADDR
    zmqctx = zmq.init(1)

    local pull = zmqctx:socket(zmq.PULL)
    assert(pull:bind(pull_addr))

    local pub = zmqctx:socket(zmq.PUB)
    assert(pub:bind(pub_addr))

    local tunnel = assert(tuntap.open(iface_path))

    tunnel:settimeout(0)
    copas.addthread(publisher(tunnel, zmqcopas.wrap(pub)))
    copas.addthread(retriever(tunnel, zmqcopas.wrap(pull)))
end

init(...)
copas.loop()
