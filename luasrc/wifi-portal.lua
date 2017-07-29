#!/usr/bin/lua

local ev = require "ev"
local evmg = require "evmongoose"
local cjson = require "cjson"
local log = require "wifi-portal.log"
local conf = require "wifi-portal.conf"
local util = require "wifi-portal.util"
local http = require "wifi-portal.http"
local ping = require "wifi-portal.ping"
local wx = require "wifi-portal.wx"
local posix = evmg.posix

local ARGV = arg
local inspect_configuration

function usage()
	print("Usage:", ARGV[0], "[options]")
	print([[
        -c file         Configuration file, default is '/etc/wp.conf'
        -i              Inspect Configuration
        -d              Log to stderr
	]])
	os.exit()
end

local function parse_commandline()	
	for o, optarg in posix.getopt(ARGV, "hc:id") do
		if o == "c" then
			conf.file = optarg
		elseif o == "i" then
			inspect_configuration = true
		elseif o == "d" then
			conf.log_to_stderr = true
		else
			usage()
		end
	end
end

local function main()
	local loop = ev.Loop.default
	local mgr = evmg.init()

	util.init(ev, loop)
	
	parse_commandline()
	conf.parse_conf()
	
	if inspect_configuration then conf.show() end

	log.init()

	ev.Signal.new(function(loop, sig, revents)
		loop:unloop()
	end, ev.SIGINT):start(loop)

	util.update_interface(conf.ifname)
	util.add_trusted_ip(conf.authserv_hostname)
	
	http.start(mgr)
	ping.start(mgr, loop)

	util.enable(true)

	loop:loop()
	util.enable(false)
	log.info("exit...")
	log.close()	
end

main()

