#!/usr/bin/lua

local ev = require("ev")
local evmg = require("evmongoose")
local posix = require('posix')
local cjson = require("cjson")
local syslog = require("syslog")
local conf = require 'wifi-portal.conf'
local util = require 'wifi-portal.util'

local ARGV = arg
local only_show_conf

local mgr = evmg.init()

local function logger(...)
	local opt = syslog.LOG_ODELAY
	if conf.log_to_stderr then
		opt = opt + syslog.LOG_PERROR 
	end
	syslog.openlog("wifi-portal", opt, "LOG_USER")
	syslog.syslog(...)
	syslog.closelog()
end

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
		local uri = msg.uri

		--Redirect them to auth server
		local authurl = string.format("http://%s:%d/wifidog/login?gw_address=%s&gw_port=%d&ip=%s&mac=%s", 
			conf.authserv_hostname, conf.authserv_http_port, conf.gw_address, conf.gw_port, msg.remote_addr, util.arp_get_mac(conf.ifname, msg.remote_addr))
		mgr:http_send_redirect(nc, 302, authurl)
	end	
end

local function main()
	local loop = ev.Loop.default
	
	parse_commandline()
	conf.parse_conf()
	conf.gw_id = util.get_iface_mac(conf.ifname)
	conf.gw_address = util.get_iface_ip(conf.ifname)
	
	if only_show_conf then conf.show() end

	ev.Signal.new(function(loop, sig, revents)
		loop:unloop()
	end, ev.SIGINT):start(loop)

	util.add_trusted_ip(conf.authserv_hostname)
	
	mgr:bind(conf.gw_port, ev_handle, {proto = "http"})

	logger("LOG_INFO", "start...")
	
	loop:loop()
	mgr:destroy()

	logger("LOG_INFO", "exit...")
end

main()
