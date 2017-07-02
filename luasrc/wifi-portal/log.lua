module(..., package.seeall)

local evmg = require "evmongoose"
local conf = require "wifi-portal.conf"
syslog = evmg.syslog

function open(ident, option, facility)
	syslog.openlog(ident, option, facility)
end

function close()
	syslog.closelog()
end

function logger(level, ...)
	syslog.syslog(level, table.concat({...}, "\t"))
end

function info(...)
	logger(syslog.LOG_INFO, ...)
end

function notice(...)
	logger(syslog.LOG_NOTICE, ...)
end

function warning(...)
	logger(syslog.LOG_WARNING, ...)
end

function error(...)
	logger(syslog.LOG_ERR, ...)
end

function crit(...)
	logger(syslog.LOG_CRIT, ...)
end

function alert(...)
	logger(syslog.LOG_ALERT, ...)
end

function emerg(...)
	logger(syslog.LOG_EMERG, ...)
end

