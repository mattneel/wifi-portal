#!/usr/bin/lua

local ev = require "ev"
local evmg = require "evmongoose"
local posix = require 'posix'
local cjson = require "cjson"
local log = require "wifi-portal.log"
local conf = require "wifi-portal.conf"
local util = require "wifi-portal.util"
local http = require "wifi-portal.http"
local ping = require "wifi-portal.ping"

local ARGV = arg
local only_show_conf

local mgr = evmg.init()

function usage()
	print("Usage:", ARGV[0], "options")
	print([[
        -s              Only show config
        -d              Log to stderr
        -i              default is eth0
        -c              Config file path
	]])
	os.exit()
end

local function parse_commandline()
	local long = {
		{"help",  "none", 'h'}
	}
	
	for r, optarg, optind, longindex in posix.getopt(ARGV, "hsdi:c:", long) do
		if r == '?' or r == "h" then
			usage()
		end
		
		if r == "d" then
			conf.log_to_stderr = true
		elseif r == "i" then
			conf.ifname = optarg
		elseif r == "s" then
			only_show_conf = true
		elseif r == "c" then
			conf.file = optarg
		else
			usage()
		end
	end
end

local function ev_handle(nc, event, msg)
	if event == evmg.MG_EV_HTTP_REQUEST then
		return http.dispach(mgr, nc, msg)
	end
end

local function main()
	local loop = ev.Loop.default
	
	parse_commandline()
	conf.parse_conf()
	
	if only_show_conf then conf.show() end

	ev.Signal.new(function(loop, sig, revents)
		loop:unloop()
	end, ev.SIGINT):start(loop)

	util.add_trusted_ip(conf.authserv_hostname)
	
	mgr:bind(conf.gw_port, ev_handle, {proto = "http"})
	mgr:bind(conf.gw_ssl_port, ev_handle, {proto = "http", ssl_cert = "/etc/wifi-portal/wp.crt", ssl_key = "/etc/wifi-portal/wp.key"})

	ping.start()

	log.info("start...")
	log.info("Listen on http:", conf.gw_port)
	log.info("Listen on https:", conf.gw_ssl_port)
	
	loop:loop()
	mgr:destroy()

	log.info("exit...")
end

main()

