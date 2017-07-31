include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-portal
PKG_VERSION:=2017-7-31
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/zhaojh329/wifi-portal.git
PKG_SOURCE_VERSION:=fa1f6e70410eed81dcef3e928378395242548fd8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/$(PKG_NAME)
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+evmongoose-lua +libiwinfo-lua +kmod-wifi-portal
  TITLE:=A very efficient captive portal solution
endef

define KernelPackage/$(PKG_NAME)
  SUBMENU:=Network Support
  TITLE:=Kernel module for wifi-portal
  DEPENDS:=+kmod-nf-nat
  FILES:=$(PKG_BUILD_DIR)/kmod/wifi-portal.ko
  AUTOLOAD:=$(call AutoLoad,70,wifi-portal)
endef

include $(INCLUDE_DIR)/kernel-defaults.mk

define Build/Compile
	$(KERNEL_MAKE) SUBDIRS="$(PKG_BUILD_DIR)"/kmod modules
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/usr/lib/lua $(1)/etc/wifi-portal
	$(INSTALL_BIN) ./files/wifi-portal.init $(1)/etc/init.d/wifi-portal
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/luasrc/wifi-portal.lua $(1)/usr/sbin/wifi-portal
	$(CP) $(PKG_BUILD_DIR)/luasrc/wifi-portal $(1)/usr/lib/lua

	$(CP) ./files/wp.crt $(1)/etc/wifi-portal
	$(CP) ./files/wp.key $(1)/etc/wifi-portal

	$(CP) ./files/internet-offline.html $(1)/etc/wifi-portal
	$(CP) ./files/authserver-offline.html $(1)/etc/wifi-portal
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call KernelPackage,$(PKG_NAME)))
