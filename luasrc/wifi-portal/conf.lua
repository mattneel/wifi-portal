module(..., package.seeall)

local uci = require "uci"
local util = require "wifi-portal.util"

log_to_stderr = false
ifname = "br-lan"
gw_id = nil
gw_address = nil
gw_port = "2060"
gw_ssl_port = "8443"

authserv_host = "192.168.0.100"
authserv_port = "8900"
authserv_path = "/wifidog/"
authserv_ping_path_fragment = "ping"
authserv_login_path_fragment = "login"
authserv_auth_path_fragment = "auth"
authserv_portal_path_fragment = "portal"
authserv_message_path_fragment = "gw_message"
authserv_ssl = false

authserv_url = nil
authserv_ping_url = nil
authserv_login_url = nil
authserv_auth_url = nil
authserv_portal_url = nil
authserv_message_url = nil

started_time = nil
authserv_offline = true

checkinterval = 60
clienttimeout = 5	-- 5 * 60s = 300s

wlan_ifname = "wlan0"

popular_server = {"www.baidu.com", "qq.com"}

function show()
	print("log_to_stderr:", log_to_stderr)

	print("ifname:", ifname)
	print("gw_id:", gw_id)
	print("gw_port:", gw_port)
	print("gw_ssl_port:", gw_ssl_port)
	print("gw_address:", gw_address)

	print("authserv_ping_url:", authserv_ping_url)
	print("authserv_login_url:", authserv_login_url)
	print("authserv_auth_url:", authserv_auth_url)
	print("authserv_portal_url:", authserv_portal_url)
	print("authserv_message_url:", authserv_message_url)

	print("popular_server:")
	for _, v in ipairs(popular_server) do
		print("", v)
	end
	
	os.exit()
end

function parse_conf()
	local c = uci.cursor()
	c:foreach("wifi-portal", "gateway", function(s)
		
		if s.ifname and #s.ifname > 0 then
			ifname = s.ifname
		end
		
		if s.port and #s.port > 0 then
			gw_port = s.port
		end

		if s.ssl_port and #s.ssl_port > 0 then
			gw_ssl_port = s.ssl_port
		end

		if s.checkinterval and #s.checkinterval > 0 then
			checkinterval = s.checkinterval
		end

		if s.clienttimeout and #s.clienttimeout > 0 then
			clienttimeout = s.clienttimeout
		end

		if s.wlan_ifname and #s.wlan_ifname > 0 then
			wlan_ifname = s.wlan_ifname
		end
	end)
	
	c:foreach("wifi-portal", "authserver", function(s)
		if s.host and #s.host > 0 then
			authserv_host = s.host
		end

		if s.port and #s.port > 0 then
			authserv_port = s.port
		end

		if s.path and #s.path > 0 then
			authserv_path = s.path
		end
	end)

	c:foreach("wifi-portal", "popular_server", function(s)
		if s.server and #s.server > 0 then
			popular_server = s.server
		end
	end)

	started_time = os.time()
	gw_id = util.get_iface_mac(ifname)
	gw_address = util.get_iface_ip(ifname)
	
	authserv_url = string.format("%s://%s:%s%s",
			authserv_ssl and "https" or "http", authserv_host, authserv_port, authserv_path)

	authserv_ping_url = string.format("%s%s?gw_id=%s&sys_uptime=%%s&sys_memfree=%%s&sys_load=%%s&wifidog_uptime=%%s",
			authserv_url, authserv_ping_path_fragment, gw_id)
			
	authserv_login_url = string.format("%s%s?gw_address=%s&gw_port=%s&bssid=%s&ip=%%s&mac=%%s&ssid=%%s",
			authserv_url, authserv_login_path_fragment, gw_address, gw_port, util.get_bssid(wlan_ifname))
			
	authserv_auth_url = string.format("%s%s?stage=%%s&gw_id=%sip=%%s&mac=%%s&token=%%s&incoming=%%s&outgoing=%%s",
			authserv_url, authserv_auth_path_fragment, gw_id)
			
	authserv_portal_url = string.format("%s%s?gw_id=%s", authserv_url, authserv_portal_path_fragment, gw_id)

	authserv_message_url = string.format("%s%s?message=%%s", authserv_url, authserv_message_path_fragment)
end
