module(..., package.seeall)

local ev = require "ev"
local evmg = require "evmongoose"
local log = require "wifi-portal.log"
local conf = require "wifi-portal.conf"
local util = require "wifi-portal.util"

local loop
local mgr

local last_online_time = 0
local last_offline_time = 0
local last_auth_online_time = 0
local last_auth_offline_time = 0

function is_online()
    if last_online_time == 0 or last_offline_time - last_online_time >= conf.checkinterval * 2 - 10 then
		-- We're probably offline
        return false
	end

	--We're probably online
	return true
end

function is_auth_online()
	if not is_online() then
		-- If we're not online auth is definately not online
		return false
	elseif last_auth_online_time == 0 or last_auth_offline_time - last_auth_online_time >= conf.checkinterval * 2 then
		-- Auth is  probably offline
		return false
	else
		-- Auth is probably online
		return true
	end
end

function mark_auth_offline()
	local before
    local after

    before = is_auth_online()
    last_auth_offline_time = os.time()
    after = is_auth_online()

    if before ~= after then
        log.info("AUTH_ONLINE became", after and "ON" or "OFF")
    end
end

local function mark_auth_online()
	local before
    local after

    before = is_auth_online()
    last_auth_online_time = os.time()
    after = is_auth_online()

    if before ~= after then
        log.info("AUTH_ONLINE became", after and "ON" or "OFF")
    end
end

local function mark_offline_time()
	local before
    local after

    before = is_online();
    last_offline_time = os.time()
    after = is_online()
	
    if before ~= after then
        log.info("ONLINE status became", after and "ON" or "OFF")
    end
end

local function mark_online()
	local before
    local after

    before = is_online();
    last_online_time = os.time()
    after = is_online()

    if before ~= after then
        log.info("ONLINE status became", after and "ON" or "OFF")
    end
end

local function dns_resolve_cb(ctx, domain, ip, err)
	if ip and #ip > 0 then
		mark_online()
	else
		log.info("dns query error:", err)
	end
end

local function check_internet_available()
	if not conf.popular_server or #conf.popular_server == 0 then return end

	mark_offline_time()
	
	for _, v in ipairs(conf.popular_server) do
		mgr:dns_resolve_async(dns_resolve_cb, v, {max_retries = 1, timeout = 2})
	end
end

function start(_mgr,   _loop)
	mgr = _mgr
	loop = _loop

	ev.Timer.new(function(loop, timer, revents)
		check_internet_available()
	end, 0.1, conf.checkinterval):start(loop)
	
	ev.Timer.new(function(loop, timer, revents)
		local sysinfo = util.ubus("system", "info")
		local ping_url = string.format(conf.authserv_ping_url, sysinfo.uptime, sysinfo.memory.free, sysinfo.load[1], os.time() - conf.started_time)

		mgr:connect_http(function(con, event)
			if event == evmg.MG_EV_CONNECT then
				local result = con:get_evdata()
				if not result.connected then
					mark_auth_offline()
				end
			elseif event == evmg.MG_EV_HTTP_REPLY then
				con:set_flags(evmg.MG_F_CLOSE_IMMEDIATELY)
				local hm = con:get_evdata()
				if hm.status_code ~= 200 then
					mark_auth_offline()
				else
					local body = con:get_http_body()
					if not body or not body:match("Pong") then
						log.info("Auth server did NOT say Pong!", body or "")
						mark_auth_offline()
					else
						mark_auth_online()
					end
				end
			elseif event == MG_EV_CLOSE then
			end
		end, ping_url)
	end, 0.1, conf.checkinterval):start(loop)

	log.info("ping start...")
end
