module(..., package.seeall)

local evmg = require "evmongoose"
local log = require "wifi-portal.log"
local conf = require "wifi-portal.conf"
local util = require "wifi-portal.util"

function http_printf(con, fmt, ...)
	 con:send_http_head(200, -1)
	 con:send_http_chunk(string.format(fmt, ...))
	 con:send_http_chunk("")
end

function http_callback_404(con)
	--Redirect them to auth server
	local remote_addr = con:remote_addr()
	local mac = util.arp_get_mac(conf.ifname, remote_addr)

	if not mac then
		http_printf(con, "Error: Unable to get your Mac address")
	else
		con:send_http_redirect(302, string.format(conf.authserv_login_url, remote_addr, mac))
	end	
end

function http_callback_auth(con)
	local token = con:get_http_var("token")

	if not token then
		http_printf(con, "Error: Unable to get your token")
		return
	end

	local mgr = con:get_mgr()
	local remote_addr = con:remote_addr()
	local mac = util.arp_get_mac(conf.ifname, remote_addr)
	mgr:connect_http(function(con2, event)
		if event == evmg.MG_EV_CONNECT then
			local s, err = con2:connected()
			if s then
				util.mark_auth_online()
			else
				util.mark_auth_offline()
				log.info("auth server offline:", err)
			end
		elseif event == evmg.MG_EV_HTTP_REPLY then
			con2:set_flags(evmg.MG_F_CLOSE_IMMEDIATELY)

			local authcode = con2:body():match("Auth: (%d)")
			if authcode == "1" then
				-- Client was granted access by the auth server
				con:send_http_redirect(302, conf.authserv_portal_url)
				util.add_trusted_mac(util.arp_get_mac(conf.ifname, remote_addr))
			else
				-- Client was denied by the auth server
				con:send_http_redirect(302, string.format(conf.authserv_message_url, "denied"))
			end
			
		end
	end, string.format(conf.authserv_auth_url, remote_addr, mac, token))
end

local function dispach(con)
	local uri = con:uri()

--[[
	log.info("--------------dispach-----------------------")
	log.info("method:", con:method())
	log.info("uri:", con:uri())
	log.info("proto:", con:proto())
	log.info("remote_addr:", con:remote_addr())

	for k, v in pairs(con:headers()) do
		log.info(k, ":", v)
	end
--]]

	if uri == "/wifidog/auth" then
		http_callback_auth(con)
		return true
	else
		http_callback_404(con)
		return true
	end
end

function start(mgr)
	local function ev_handle(con, event)
		if event == evmg.MG_EV_HTTP_REQUEST then
			return dispach(con)
		end
	end

	local opt = {proto = "http"}
	mgr:listen(ev_handle, conf.gw_address .. ":" .. conf.gw_port, opt)

	opt.ssl_cert = "/etc/wifi-portal/wp.crt"
	opt.ssl_key = "/etc/wifi-portal/wp.key"
	mgr:listen(ev_handle, conf.gw_address .. ":" .. conf.gw_ssl_port, opt)

	log.info("http start...")
end