module(..., package.seeall)

local util = require "wifi-portal.util"

file = "/etc/wifi-portal.conf"
log_to_stderr = false
ifname = "br-lan"
gw_id = nil
gw_address = nil
gw_port = "2060"
gw_ssl_port = "8443"

authserv_hostname = "192.168.0.100"
authserv_port = "8900"
authserv_path = "/wifidog/"
authserv_login_path_fragment = "login"
authserv_auth_path_fragment = "auth"
authserv_portal_path_fragment = "portal"
authserv_message_path_fragment = "gw_message"
authserv_ssl = false

authserv_url = nil
authserv_login_url = nil
authserv_auth_url = nil
authserv_portal_url = nil
authserv_message_url = nil

function show()
	print("log_to_stderr:", log_to_stderr)

	print("file:", file)
	print("ifname:", ifname)
	print("gw_id:", gw_id)
	print("gw_port:", gw_port)
	print("gw_ssl_port:", gw_ssl_port)
	print("gw_address:", gw_address)
	
	print("authserv_hostname:", authserv_hostname)
	print("authserv_port:", authserv_port)
	print("authserv_path:", authserv_path)
	print("authserv_login_path_fragment:", authserv_login_path_fragment)
	print("authserv_auth_path_fragment:", authserv_auth_path_fragment)
	print("authserv_portal_path_fragment:", authserv_portal_path_fragment)
	print("authserv_message_path_fragment:", authserv_message_path_fragment)
	print("authserv_ssl:", authserv_ssl)
	print("authserv_url:", authserv_url)

	print("authserv_login_url:", authserv_login_url)
	print("authserv_auth_url:", authserv_auth_url)
	print("authserv_portal_url:", authserv_portal_url)
	print("authserv_message_url:", authserv_message_url)
	
	os.exit()
end

function parse_conf()
	-- todo parse conf file

	gw_id = util.get_iface_mac(ifname)
	gw_address = util.get_iface_ip(ifname)

	authserv_url = string.format("%s://%s:%s%s",
			authserv_ssl and "https" or "http", authserv_hostname, authserv_port, authserv_path)

	authserv_login_url = string.format("%s%s?gw_address=%s&gw_port=%s&ip=%%s&mac=%%s", 
			authserv_url, authserv_login_path_fragment, gw_address, gw_port)
			
	authserv_auth_url = string.format("%s%s?stage=login&gw_id=%sip=%%s&mac=%%s&token=%%s", 
			authserv_url, authserv_auth_path_fragment, gw_id)
			
	authserv_portal_url = string.format("%s%s?gw_id=%s", authserv_url, authserv_portal_path_fragment, gw_id)

	authserv_message_url = string.format("%s%s?message=%%s", authserv_url, authserv_message_path_fragment)
end
