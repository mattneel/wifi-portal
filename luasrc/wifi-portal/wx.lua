module(..., package.seeall)

local ev = require "ev"
local evmg = require "evmongoose"
local log = require "wifi-portal.log"
local util = require "wifi-portal.util"


local function dns_resolve_cb(ctx, domain, ip, err)
	if ip then
		log.info("parsed", domain)
		for _, v in ipairs(ip) do
			util.add_trusted_ip(v)
		end
	else
		log.error("parse failed:", domain, err)
	end
end

function init(mgr)	
	log.info("Init Wei Xin...")
	
	mgr:dns_resolve_async(dns_resolve_cb, "wifi.weixin.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "szextshort.weixin.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "dns.weixin.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "short.weixin.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "long.weixin.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "mp.weixin.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "res.wx.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "wx.qlogo.cn", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "minorshort.weixin.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "adfilter.imtt.qq.com", {max_retries = 1, timeout = 2})
	mgr:dns_resolve_async(dns_resolve_cb, "log.tbs.qq.com", {max_retries = 1, timeout = 2})
end

