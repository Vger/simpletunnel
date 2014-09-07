simpletunnel
============

Access to tuntap interfaces via ZeroMQ.

tunendpoint.lua binds a ZeroMQ PULL and a PUB socket to retrieve and publish frames from the TUN/TAP interface, respectively.

tuntransfer.lua connects two instances of tunendpoint.lua together, to transfer data between two TUN/TAP interfaces.

Installation
============

Latest Git Revision
-------------------

With LuaRocks 2.1.2:

	$ luarocks install https://raw.githubusercontent.com/Vger/simpletunnel/master/rockspecs/simpletunnel-scm-0.rockspec
