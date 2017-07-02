module(..., package.seeall)

local syslog = require "syslog"
local conf = require "wifi-portal.conf"

function logger(level, ...)
	local opt = syslog.LOG_ODELAY

	if conf.log_to_stderr then
		opt = opt + syslog.LOG_PERROR 
	end
	
	syslog.openlog("wifi-portal", opt, "LOG_USER")
	syslog.syslog(level, table.concat({...}, "\t"))
	syslog.closelog()
end

function info(...)
	logger("LOG_INFO", ...)
end

function notice(...)
	logger("LOG_NOTICE", ...)
end

function warning(...)
	logger("LOG_WARNING", ...)
end

function error(...)
	logger("LOG_ERR", ...)
end

function crit(...)
	logger("LOG_CRIT", ...)
end

function alert(...)
	logger("LOG_ALERT", ...)
end

function emerg(...)
	logger("LOG_EMERG", ...)
end

