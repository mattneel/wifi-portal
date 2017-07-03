module(..., package.seeall)

local ev = require "ev"
local evmg = require "evmongoose"
local log = require "wifi-portal.log"
local conf = require "wifi-portal.conf"
local util = require "wifi-portal.util"

local function ping_resp_cb(msg)
	local body = msg.body
	if not body or not body:match("Pong") then
		log.info("Auth server did NOT say Pong!", msg.body or "")
	else
	end
end

function start(mgr,  loop)	
	ev.Timer.new(function(loop, timer, revents)
		local sysinfo = util.ubus("system", "info")
		local ping_url = string.format(conf.authserv_ping_url, sysinfo.uptime, sysinfo.memory.free, sysinfo.load[1], os.time() - conf.started_time)
		
		mgr:connect_http(ping_url, function(nc, event, msg)
			if event == evmg.MG_EV_CONNECT then
				if msg.connected then
					util.mark_auth_online()
				else
					util.mark_auth_offline()
					log.info("auth server offline:", msg.err)
				end
			elseif event == evmg.MG_EV_HTTP_REPLY then
				mgr:set_connection_flags(nc, evmg.MG_F_CLOSE_IMMEDIATELY)
				ping_resp_cb(msg)
			end
		end)
	end, 0.1, conf.checkinterval):start(loop)

	log.info("ping start...")
end
