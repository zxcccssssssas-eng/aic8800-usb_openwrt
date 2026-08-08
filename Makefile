include $(TOPDIR)/rules.mk

PKG_NAME:=kmod-aic8800-usb-shenmintao
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/shenmintao/aic8800d80.git
# issue-76-openwrt-cfg80211 branch HEAD: cfg80211 backport ABI fixes for OpenWrt
PKG_SOURCE_VERSION:=bef3cc252f29b21f2e25bbc2cbbd737cd4fa6e65
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.zst

PKG_MIRROR_HASH:=

PKG_MAINTAINER:=NickBash11 <nybash110998@gmail.com>
PKG_LICENSE:=GPL-2.0

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/aic8800-usb-shenmintao
	SUBMENU:=Wireless Drivers
	TITLE:=AIC8800 USB WiFi Driver (Tenda/Friddle)
	DEPENDS:=+kmod-cfg80211 +kmod-mac80211 +kmod-usb-core +kmod-usb2
	FILES:= \
		$(PKG_BUILD_DIR)/drivers/aic8800/aic8800_fdrv/aic8800_fdrv.ko \
		$(PKG_BUILD_DIR)/drivers/aic8800/aic_load_fw/aic_load_fw.ko
	AUTOLOAD:=$(call AutoLoad,50,aic_load_fw aic8800_fdrv)
endef

define KernelPackage/aic8800-usb-shenmintao/description
	Driver for AIC8800 USB WiFi (Tenda AX300 etc.)
endef

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)/drivers/aic8800/" \
		KBUILD_EXTRA_SYMBOLS="$(LINUX_DIR)/../symvers/mac80211.symvers" \
		NOSTDINC_FLAGS="$(KERNEL_NOSTDINC_FLAGS) -I$(STAGING_DIR)/usr/include/mac80211-backport/uapi -I$(STAGING_DIR)/usr/include/mac80211-backport -I$(STAGING_DIR)/usr/include/mac80211/uapi -I$(STAGING_DIR)/usr/include/mac80211 -include backport/autoconf.h -include backport/backport.h" \
		CFLAGS_MODULE="-g" \
		modules
endef

define KernelPackage/aic8800-usb-shenmintao/install
	$(INSTALL_DIR) $(1)/lib/firmware/aic8800D80
	$(CP) $(PKG_BUILD_DIR)/fw/aic8800D80/*.bin $(1)/lib/firmware/aic8800D80/
endef

$(eval $(call KernelPackage,aic8800-usb-shenmintao))
