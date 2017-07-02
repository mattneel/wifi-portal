# WiFi-Portal([中文](https://github.com/zhaojh329/wifi-portal/blob/master/README_ZH.md))

![](https://img.shields.io/badge/license-GPLV3-brightgreen.svg?style=plastic "License")

WiFi-Portal is a very efficient captive portal solution for wireless
router which with embedded linux(LEDE/Openwrt) system and it's using the Lua language. 
It's referenced wifidog and apfree_wifidog, and it's a whole new one captive portal solution. Unlike
wifidog and apfree_wifidog, wifi-portal does write kernel module to implement
authentication management instead of using iptables to create firewall rules.

## features:
* using the Lua language
* Based on [evmongoose](https://github.com/zhaojh329/evmongoose)(mongoose, libev, lua-ev)
* Single threaded, fully asynchronous
* Writing kernel module to implement authentication management instead of using iptables to create firewall rules
* Support HTTPS
* Alternative openssl and mbedtls

# How to use
## Install Auth Server Demo for WiFi-portal on Ubuntu
	sudo apt install nginx nginx-extras
	git clone https://github.com/zhaojh329/wifi-portal.git
	sudo cp -r wifi-portal/authserver/nginx/sites-available /etc/nginx
	sudo ln -s /etc/nginx/sites-available/wifidog /etc/nginx/sites-enabled/wifidog
	sudo cp -r wifi-portal/authserver/www/wifidog /var/www/
	sudo nginx -s reload
	
## Modify config of Auth Server(/etc/nginx/sites-available/wifidog)

## Install WiFi-Portal on OpenWRT/LEDE
	git clone https://github.com/zhaojh329/lua-ev-openwrt.git
	cp -r lua-ev-openwrt openwrt_dir/package/lua-ev
	
	git clone https://github.com/zhaojh329/evmongoose.git
	cp -r evmongoose/openwrt openwrt_dir/package/evmongoose
	
	git clone https://github.com/zhaojh329/wifi-portal.git
	cp -r wifi-portal/openwrt openwrt_dir/package/wifi-portal
	
	cd openwrt_dir
	./scripts/feeds update -a
	./scripts/feeds install -a
	
	make menuconfig
	Network  --->
		Captive Portals  --->
			<*> wifi-portal
			
	make package/wifi-portal/compile V=s

# How To Contribute
Feel free to create issues or pull-requests if you have any problems.

**Please read [contributing.md](https://github.com/zhaojh329/wifi-portal/blob/master/contributing.md)
before pushing any changes.**

# Thanks for the following project
* [evmongoose](https://github.com/zhaojh329/evmongoose)
* [wifidog-gateway](https://github.com/wifidog/wifidog-gateway)
* [apfree_wifidog](https://github.com/liudf0716/apfree_wifidog)
* [mongoose](https://github.com/cesanta/mongoose)
* [libev](https://github.com/kindy/libev)
* [lua-ev](https://github.com/brimworks/lua-ev)

# If the project is helpful to you, please do not hesitate to star. Thank you!

