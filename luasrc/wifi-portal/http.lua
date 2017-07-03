module(..., package.seeall)

local evmg = require "evmongoose"
local log = require "wifi-portal.log"
local conf = require "wifi-portal.conf"
local util = require "wifi-portal.util"

function http_printf(mgr, nc, fmt, ...)
	 mgr:send_head(nc, 200, -1)
	 mgr:print_http_chunk(nc, string.format(fmt, ...))
	 mgr:print_http_chunk(nc, "")
end

function http_callback_404(mgr, nc, msg)
	--Redirect them to auth server
	local mac = util.arp_get_mac(conf.ifname, msg.remote_addr)

	if not mac then
		http_printf(mgr, nc, "Error: Unable to get your Mac address")
	else
		mgr:http_send_redirect(nc, 302, string.format(conf.authserv_login_url, msg.remote_addr, mac))
	end	
end

function http_callback_auth(mgr, nc, msg)
	local token = mgr:get_http_var(msg.hm, "token")

	if not token then
		http_printf(mgr, nc, "Error: Unable to get your token")
		return
	end

	local mac = util.arp_get_mac(conf.ifname, msg.remote_addr)
	mgr:connect_http(string.format(conf.authserv_auth_url, msg.remote_addr, mac, token), function(nc2, event, msg2)
		if event == evmg.MG_EV_CONNECT then
			if msg2.connected then
				util.mark_auth_online()
			else
				util.mark_auth_offline()
				log.info("auth server offline:", msg.err)
			end
		elseif event == evmg.MG_EV_HTTP_REPLY then
			mgr:set_connection_flags(nc2, evmg.MG_F_CLOSE_IMMEDIATELY)

			local authcode = msg2.body:match("Auth: (%d)")
			if authcode == "1" then
				-- Client was granted access by the auth server
				mgr:http_send_redirect(nc, 302, conf.authserv_portal_url)
				util.add_trusted_mac(util.arp_get_mac(conf.ifname, msg.remote_addr))
			else
				-- Client was denied by the auth server
				mgr:http_send_redirect(nc, 302, string.format(conf.authserv_message_url, "denied"))
			end
			
		end
	end)
end

local function dispach(mgr, nc, msg)
	local uri = msg.uri

--[[
	log.info("--------------dispach-----------------------")
	log.info("method:", msg.method)
	log.info("uri:", msg.uri)
	log.info("proto:", msg.proto)
	log.info("remote_addr:", msg.remote_addr)

	for k, v in pairs(msg.headers) do
		log.info(k, ":", v)
	end
--]]

	if uri == "/wifidog/auth" then
		http_callback_auth(mgr, nc, msg)
		return true
	else
		http_callback_404(mgr, nc, msg)
		return true
	end
end

function start(mgr)
	local function ev_handle(nc, event, msg)
		if event == evmg.MG_EV_HTTP_REQUEST then
			return dispach(mgr, nc, msg)
		end
	end

	local opt = {proto = "http"}
	mgr:bind(conf.gw_address .. ":" .. conf.gw_port, ev_handle, opt)

	opt.ssl_cert = "/etc/wifi-portal/wp.crt"
	opt.ssl_key = "/etc/wifi-portal/wp.key"
	mgr:bind(conf.gw_address .. ":" .. conf.gw_ssl_port, ev_handle, opt)

	log.info("http start...")
end