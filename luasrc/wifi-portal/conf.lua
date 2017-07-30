module(..., package.seeall)

local util = require "wifi-portal.util"

file = "/etc/wp.conf"
log_to_stderr = false
ifname = "br-lan"
gw_id = nil
gw_address = nil
gw_port = "2060"
gw_ssl_port = "8443"

wx = true
authserv_hostname = "192.168.0.100"
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
clienttimeout = 5

wlan_ifname = "ra0"

popular_server = {"www.baidu.com", "qq.com"}

function show()
	print("log_to_stderr:", log_to_stderr)

	print("file:", file)
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
	
	os.exit()
end

function parse_conf()
	-- todo parse conf file

	started_time = os.time()
	gw_id = util.get_iface_mac(ifname)
	gw_address = util.get_iface_ip(ifname)
	
	authserv_url = string.format("%s://%s:%s%s",
			authserv_ssl and "https" or "http", authserv_hostname, authserv_port, authserv_path)

	authserv_ping_url = string.format("%s%s?gw_id=%s&sys_uptime=%%s&sys_memfree=%%s&sys_load=%%s&wifidog_uptime=%%s",
			authserv_url, authserv_ping_path_fragment, gw_id)
			
	authserv_login_url = string.format("%s%s?gw_address=%s&gw_port=%s&bssid=%sip=%%s&mac=%%s&ssid=%%s",
			authserv_url, authserv_login_path_fragment, gw_address, gw_port, util.get_bssid(wlan_ifname))
			
	authserv_auth_url = string.format("%s%s?stage=login&gw_id=%sip=%%s&mac=%%s&token=%%s", 
			authserv_url, authserv_auth_path_fragment, gw_id)
			
	authserv_portal_url = string.format("%s%s?gw_id=%s", authserv_url, authserv_portal_path_fragment, gw_id)

	authserv_message_url = string.format("%s%s?message=%%s", authserv_url, authserv_message_path_fragment)
end
