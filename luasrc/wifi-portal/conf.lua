module(..., package.seeall)

log_to_stderr = false
ifname = "br-lan"
file = "/etc/wifi-portal.conf"
gw_port = 2060
authserv_hostname = "192.168.0.100"
authserv_http_port = 80

function show()
	print("log_to_stderr", log_to_stderr)
	print("ifname", ifname)
	print("gw_id", gw_id)
	print("file", file)
	print("gw_port", gw_port)
	print("gw_address", gw_address)
	print("authserv_hostname", authserv_hostname)
	print("authserv_http_port", authserv_http_port)
	os.exit()
end

function parse_conf()
end
