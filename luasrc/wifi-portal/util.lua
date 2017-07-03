module(..., package.seeall)

local libubus = require "ubus"

local ubus_con = libubus.connect()
if not ubus_con then
	error("Failed to connect to ubus")
end
		
function ubus(object, method, param)
	return ubus_con:call(object, method, param or {})
end

--[[
Example:

local longopts = {
	{"host", true, "h"},
	{"port", true, "p"},
	{"help", false, 0},
}

print("option", "optarg", "long-option")
for o, optarg, lo in getopt(arg, "h:p:dt:", longopts) do
	print(o, optarg, lo)
end
--]]

function getopt(args, optstring, longopts)
	local program = args[0]
	local i = 1
	
	return function()
		local a = args[i]
		if not a then return nil end
		
		if a:sub(1, 2) == "--" then
			local name = a:sub(3)
			
			if not name or #name == 0 then
				i = i + 1
				return "?"
			end
			
			for _, v in ipairs(longopts) do
				if v[1] == name then
					local optarg = v[2] and args[i + 1] or nil
					
					if v[2] then
						if not optarg then
							print(program .. ":", "option requires an argument -- '" .. name .. "'")
							os.exit()
						end
						
						i = i + 1
					end
					
					i = i + 1
					return v[3], optarg, v[1]
				end
			end
			
			print(program .. ":", "invalid option -- '" .. name .. "'")
			
		elseif a:sub(1, 1) == "-" then
			local o = a:sub(2, 2)
			
			if not o or #o == 0 then
				i = i + 1
				return "?" 
			end
			
			if not optstring:match(o) then
				print(program .. ":", "invalid option -- '" .. o .. "'")
				os.exit()
			end
			
			local optarg
			if optstring:match(o .. ":") then
				if #a > 2 then
					optarg = a:sub(3)
				else
					optarg = args[i + 1]
					i = i + 1
				end
				
				if not optarg then
					print(program .. ":", "option requires an argument -- '" .. o .. "'")
					os.exit()
				end
			end
			
			i = i + 1
			return o, optarg
		else
			i = i + 1
			return "?"
		end
	end
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

function add_trusted_ip(ip)
	local file = io.open("/proc/wifidog/trusted_ip", "w")
	file:write("+", ip, "\n")
	file:close()
end

function add_trusted_mac(mac)
	local file = io.open("/proc/wifidog/trusted_mac", "w")
	file:write("+", mac, "\n")
	file:close()
end

function mark_auth_online()
end

function mark_auth_offline()
end
