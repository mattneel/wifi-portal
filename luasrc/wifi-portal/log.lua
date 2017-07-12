module(..., package.seeall)

local evmg = require "evmongoose"
local conf = require "wifi-portal.conf"
local posix = evmg.posix

function open(ident, option, facility)
	posix.openlog(ident, option, facility)
end

function close()
	posix.closelog()
end

function logger(level, ...)
	posix.syslog(level, table.concat({...}, "\t"))
end

function info(...)
	logger(posix.LOG_INFO, ...)
end

function notice(...)
	logger(posix.LOG_NOTICE, ...)
end

function warning(...)
	logger(posix.LOG_WARNING, ...)
end

function error(...)
	logger(posix.LOG_ERR, ...)
end

function crit(...)
	logger(posix.LOG_CRIT, ...)
end

function alert(...)
	logger(posix.LOG_ALERT, ...)
end

function emerg(...)
	logger(posix.LOG_EMERG, ...)
end

function init()
	local option = posix.LOG_ODELAY

	if conf.log_to_stderr then
		option = option + posix.LOG_PERROR 
	end
	open("wifi-portal", option, posix.LOG_USER)
end
