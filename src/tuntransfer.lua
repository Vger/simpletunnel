--[[

Transfer data from one invocation of tunendpoint.lua to
another invocation of tunendpoint.lua

Arguments to tuntransfer.lua:

 <zmq pub addr1> <zmq pull addr1> <zmq pub addr2> <zmq pull addr2>

e.g.
  "tcp://127.0.0.1:6000" "tcp://127.0.0.1:6001" "tcp://10.0.0.1:5000" "tcp://10.0.0.1:5001"
  will read frames from zeromq socket bound to 127.0.0.1:6000 and
  send them to zeromq socket bound to 10.0.0.1:5001, and read frames
  from zeromq socket bound to 10.0.0.1:5000 and send them to zeromq
  socket bound to 127.0.0.1:6001.
--]]

local zmq = require "lzmq"
local copas = require "copas"
local zmqcopas = require "zmq.copas"
local zmqctx

local function main_transfer(subskt, pushskt)
    return function()
	while true do
	    local frame = subskt:receive(1)
	    pushskt:send(frame)
	end
    end
end

local function transfer(zmqctx, subaddr, pushaddr)
    local subskt = zmqctx:socket(zmq.SUB, {connect=subaddr, subscribe={""}})
    local pushskt = zmqctx:socket(zmq.PUSH, {connect=pushaddr})
    return main_transfer(zmqcopas.wrap(subskt), zmqcopas.wrap(pushskt))
end

local function init(pubaddr1, pulladdr1, pubaddr2, pulladdr2)
    if type(pubaddr1) ~= "string" or pubaddr1 == "" then
	error("First publish address omitted.")
    end
    if type(pulladdr1) ~= "string" or pulladdr1 == "" then
	error("First pull address omitted.")
    end
    if type(pubaddr2) ~= "string" or pubaddr2 == "" then
	error("Second publish address omitted.")
    end
    if type(pulladdr2) ~= "string" or pulladdr2 == "" then
	error("Second pull address omitted.")
    end

    zmqctx = zmq.context { io_threads = 1 }

    local thread1 = transfer(zmqctx, pubaddr1, pulladdr2)
    local thread2 = transfer(zmqctx, pubaddr2, pulladdr1)
    copas.addthread(thread1)
    copas.addthread(thread2)
end

init(...)
copas.loop()
