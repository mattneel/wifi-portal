module(..., package.seeall)

local ev = require "ev"
local libubus = require "ubus"
local iwinfo = require "iwinfo"

local loop

local ubus_con = libubus.connect()
if not ubus_con then
	error("Failed to connect to ubus")
end

function init(_loop)
	loop = _loop
end

function ubus(object, method, param)
	return ubus_con:call(object, method, param or {})
end

function enable(e)
	local file = io.open("/proc/wifidog/config", "w")
	if e then
		file:write("enabled=1\n")
	else
		file:write("enabled=0\n")
	end
	file:close()
end

function get_iface_mac(ifname)
	local s = ubus("network.device", "status", {name = ifname})
	return s.macaddr:gsub(":", ""):upper()
end

function get_iface_ip(ifname)
	local r = ubus("network.interface", "dump")

	for _, v in ipairs(r.interface) do
		if v.device == ifname then
			return v["ipv4-address"][1].address
		end
	end

	return nil
end

function arp_get_mac(ifname, ip)
	for e in io.lines("/proc/net/arp") do
		local r = { }, v
		for v in e:gmatch("%S+") do
			r[#r+1] = v
		end

		if r[1] ~= "IP" then
			if ifname == r[6] and ip == r[1] then
				return r[4]
			end
		end
	end

	return nil
end

function get_ssid(ifname)
	local iw = iwinfo.type(ifname) and iwinfo[iwinfo.type(ifname)]
	if iw then
		return iw.ssid(ifname)
	end
	return nil
end

function get_bssid(ifname)
	local iw = iwinfo.type(ifname) and iwinfo[iwinfo.type(ifname)]
	if iw then
		return iw.bssid(ifname)
	end
	return nil
end

function add_trusted_ip(ip)
	local file = io.open("/proc/wifidog/trusted_ip", "w")
	file:write("+", ip, "\n")
	file:close()
end


local temppass_mac = {}
function add_trusted_mac(mac)
	local file = io.open("/proc/wifidog/trusted_mac", "w")
	file:write("+", mac, "\n")
	file:close()
	temppass_mac[mac] = nil
end

function del_trusted_mac(mac)
	local file = io.open("/proc/wifidog/trusted_mac", "w")
	file:write("-", mac, "\n")
	file:close()
end

function temporary_pass(mac, t)
	add_trusted_mac(mac)
	temppass_mac[mac] = true
	ev.Timer.new(function()
		if temppass_mac[mac] then
			del_trusted_mac(mac)
			temppass_mac[mac] = nil
		end
	end, t):start(loop)
end

function update_interface(ifname)
	local file = io.open("/proc/wifidog/config", "w")
	file:write("interface=", ifname, "\n")
	file:close()
end