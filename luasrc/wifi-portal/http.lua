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

function http_callback_404(con, hm)
	--Redirect them to auth server
	local remote_addr = hm.remote_addr
	local mac = util.arp_get_mac(conf.ifname, remote_addr)

	if not mac then
		http_printf(con, "Error: Unable to get your Mac address")
	else
		local url = string.format(conf.authserv_login_url, remote_addr, mac)
		local ssid = util.get_ssid(conf.wlan_ifname)
		local bssid = util.get_bssid(conf.wlan_ifname)

		url = url .. "&ssid=" .. ssid .. "&bssid="  .. bssid
		if conf.wx then url = url .. "&wx=1" end
		con:send_http_redirect(302, url)
	end	
end

function http_callback_auth(con, hm)
	local token = con:get_http_var("token")

	if not token then
		http_printf(con, "Error: Unable to get your token")
		return
	end

	local mgr = con:get_mgr()
	local remote_addr = hm.remote_addr
	local mac = util.arp_get_mac(conf.ifname, remote_addr)
	mgr:connect_http(function(con2, event)
		if event == evmg.MG_EV_CONNECT then
			local result = con2:get_evdata()
			if result.connected then
				util.mark_auth_online()
			else
				util.mark_auth_offline()
				log.info("auth server offline:", result.err)
			end
		elseif event == evmg.MG_EV_HTTP_REPLY then
			con2:set_flags(evmg.MG_F_CLOSE_IMMEDIATELY)

			local authcode = con2:get_http_body():match("Auth: (%d)")
			if authcode == "1" then
				-- Client was granted access by the auth server
				if conf.wx then
					http_printf(con, "Auth: 1")
				else
					con:send_http_redirect(302, conf.authserv_portal_url)
				end
				util.add_trusted_mac(util.arp_get_mac(conf.ifname, remote_addr))
			else
				-- Client was denied by the auth server
				con:send_http_redirect(302, string.format(conf.authserv_message_url, "denied"))
			end
			
		end
	end, string.format(conf.authserv_auth_url, remote_addr, mac, token))
end

local function dispach(con)
	local hm = con:get_evdata()

	if hm.uri ~= "/wifidog/auth" and hm.method ~= "GET" then
		return
	end
	
--[[
	log.info("--------------dispach-----------------------")
	log.info("method:", hm.method)
	log.info("uri:", hm.uri)
	log.info("query_string:", hm.query_string)
	log.info("proto:", hm.proto)
	log.info("remote_addr:", hm.remote_addr)

	for k, v in pairs(con:get_http_headers()) do
		log.info(k, ":", v)
	end
--]]

	if hm.uri == "/wifidog/auth" then
		http_callback_auth(con, hm)
		return true
	elseif hm.uri == "/wifidog/temppass" then
		util.temporary_pass(util.arp_get_mac(conf.ifname, hm.remote_addr), 10)
		http_printf(con, "")
	elseif hm.method ~= "POST" then	
		http_callback_404(con, hm)
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