module(..., package.seeall)

local evmg = require "evmongoose"
local log = require "wifi-portal.log"
local conf = require "wifi-portal.conf"
local util = require "wifi-portal.util"

local clients = {}

function add(mac, ip, token)
	clients[mac] = {
		ip = ip,
		token = token
	}
end

function del(mac)
	clients[mac] = nil
end

function get(mac)
	return clients[mac]
end