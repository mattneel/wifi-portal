# WiFi-Portal

![](https://img.shields.io/badge/license-GPLV3-brightgreen.svg?style=plastic "License")

WiFi-Portal是一个使用Lua语言编写的非常高效的portal认证解决方案。它参考了wifidog和apfree_wifidog，
是一个全新的portal认证解决方案，代码简洁，框架清晰。与wifidog和apfree_wifidog
不同的是，wifi-portal通过编写内核模块实现认证管理，而不是通过iptables创建防火墙规则。

## 特性:
* 兼容原版WiFiDog协议
* 使用Lua语言编写 —— 修改调试方便
* 单线程，全异步，所有操作均采用异步编程实现
* 通过编写内核模块实现认证管理，而不是通过iptables创建防火墙规则
* 支持HTTPS
* SSL库可以选择openssl或者mbedtls

# 如何使用
## 在Ubuntu上安装最简单的认证服务器
	sudo apt install nginx nginx-extras
	git clone https://github.com/zhaojh329/wifi-portal.git
	sudo cp -r wifi-portal/authserver/nginx/sites-available /etc/nginx
	sudo ln -s /etc/nginx/sites-available/wifidog /etc/nginx/sites-enabled/wifidog
	sudo cp -r wifi-portal/authserver/www/wifidog /var/www/
	sudo nginx -s reload
	
## 修改认证服务器配置(/etc/nginx/sites-available/wifidog)

## 安装WiFi-Portal到OpenWRT/LEDE
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
	Libraries  --->
		Networking  --->
			-*- evmongoose
				Configuration  --->
					[*] Enable HTTP gzip module
					Selected SSL library (OpenSSL)  --->
	Network  --->
		Captive Portals  --->
			<*> wifi-portal
			
	make package/wifi-portal/compile V=s

# 贡献代码

WiFi-Portal使用github托管其源代码，贡献代码使用github的PR(Pull Request)的流程，十分的强大与便利:

1. [创建 Issue](https://github.com/zhaojh329/wifi-portal/issues/new) - 对于较大的
	改动(如新功能，大型重构等)最好先开issue讨论一下，较小的improvement(如文档改进，bugfix等)直接发PR即可
2. Fork [wifi-portal](https://github.com/zhaojh329/wifi-portal) - 点击右上角**Fork**按钮
3. Clone你自己的fork: ```git clone https://github.com/$userid/wifi-portal.git```
4. 创建dev分支，在**dev**修改并将修改push到你的fork上
5. 创建从你的fork的**dev**分支到主项目的**dev**分支的[Pull Request] -  
	[在此](https://github.com/zhaojh329/wifi-portal)点击**Compare & pull request**
6. 等待review, 需要继续改进，或者被Merge!
	
## 感谢以下项目提供帮助
* [evmongoose](https://github.com/zhaojh329/evmongoose)
* [wifidog-gateway](https://github.com/wifidog/wifidog-gateway)
* [apfree_wifidog](https://github.com/liudf0716/apfree_wifidog)
* [mongoose](https://github.com/cesanta/mongoose)
* [libev](https://github.com/kindy/libev)
* [lua-ev](https://github.com/brimworks/lua-ev)

# 技术交流
QQ群：153530783

# 如果该项目对您有帮助，请随手star，谢谢！
