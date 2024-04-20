#
# Copyright (C) 2021 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Restrict the visibility of Android.bp files to improve build analysis time
$(call inherit-product-if-exists, vendor/google/products/sources_pixel.mk)

# Keeps flexibility for kasan and ufs builds
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_CHEETAH_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_CHEETAH_DIR)/kernel-headers

$(call inherit-product-if-exists, vendor/google_devices/pantah/prebuilts/device-vendor-ravenclaw.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs201/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs201/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/pantah/proprietary/ravenclaw/device-vendor-ravenclaw.mk)

include device/google/gs201/device-shipping-common.mk
include device/google/pantah/audio/ravenclaw/audio-tables.mk
include hardware/google/pixel/vibrator/cs40l26/device.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/lsi/lsi.mk

ifeq ($(filter factory_ravenclaw, $(TARGET_PRODUCT)),)
include device/google/gs101/uwb/uwb.mk
include device/google/pantah/uwb/uwb_calibration.mk
endif

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,ravenclaw)
$(call soong_config_set,lyric,tuning_product,cloudripper)
$(call soong_config_set,google3a_config,target_device,cloudripper)

# Init files
PRODUCT_COPY_FILES += \
	device/google/pantah/conf/init.ravenclaw.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.ravenclaw.rc

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/pantah/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.ravenclaw.rc

# insmod files
PRODUCT_COPY_FILES += \
	device/google/pantah/init.insmod.ravenclaw.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/init.insmod.ravenclaw.cfg

# Camera
PRODUCT_COPY_FILES += \
	device/google/pantah/media_profiles_ravenclaw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.uicc.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \
    device/google/pantah/nfc/libnfc-hal-st.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libnfc-hal-st.conf \
    device/google/pantah/nfc/libnfc-nci.conf:$(TARGET_COPY_OUT_PRODUCT)/etc/libnfc-nci.conf

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element@1.2-service-gto \
	android.hardware.secure_element@1.2-service-gto-ese2

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \
	device/google/pantah/nfc/libse-gto-hal.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libse-gto-hal.conf \
	device/google/pantah/nfc/libse-gto-hal2.conf:$(TARGET_COPY_OUT_VENDOR)/etc/libse-gto-hal2.conf

DEVICE_MANIFEST_FILE += \
	device/google/pantah/nfc/manifest_se.xml

# Thermal Config
PRODUCT_COPY_FILES += \
	device/google/pantah/thermal_info_config_ravenclaw.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json \
	device/google/pantah/thermal_info_config_proto.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config_proto.json

# Power HAL config
PRODUCT_COPY_FILES += \
	device/google/pantah/powerhint-ravenclaw.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# Bluetooth HAL
PRODUCT_COPY_FILES += \
	device/google/pantah/bluetooth/bt_vendor_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth/bt_vendor_overlay.conf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.bluetooth.a2dp_offload.supported=true \
    persist.bluetooth.a2dp_offload.disabled=false \
    persist.bluetooth.a2dp_offload.cap=sbc-aac-aptx-aptxhd-ldac-opus
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.firmware.selection=BCM.hcd
# default BDADDR for EVB only
PRODUCT_PROPERTY_OVERRIDES += \
	ro.vendor.bluetooth.evb_bdaddr="22:22:22:33:44:55"

# Keymaster HAL
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# Gatekeeper HAL
#LOCAL_GATEKEEPER_PRODUCT_PACKAGE ?= android.hardware.gatekeeper@1.0-service.software


# Gatekeeper
# PRODUCT_PACKAGES += \
# 	android.hardware.gatekeeper@1.0-service.software

# Keymint replaces Keymaster
# PRODUCT_PACKAGES += \
# 	android.hardware.security.keymint-service

# Keymaster
#PRODUCT_PACKAGES += \
#	android.hardware.keymaster@4.0-impl \
#	android.hardware.keymaster@4.0-service

#PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.remote
#PRODUCT_PACKAGES += android.hardware.keymaster@4.1-service.remote
#LOCAL_KEYMASTER_PRODUCT_PACKAGE := android.hardware.keymaster@4.1-service
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# PRODUCT_PROPERTY_OVERRIDES += \
# 	ro.hardware.keystore_desede=true \
# 	ro.hardware.keystore=software \
# 	ro.hardware.gatekeeper=software

# PowerStats HAL
PRODUCT_SOONG_NAMESPACES += \
    device/google/pantah/powerstats/ravenclaw

# Fingerprint HAL
GOODIX_CONFIG_BUILD_VERSION := g6_trusty
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_common.mk)
ifeq ($(filter factory%, $(TARGET_PRODUCT)),)
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_shipping.mk)
else
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_factory.mk)
endif

# WiFi Overlay
PRODUCT_PACKAGES += \
	WifiOverlay2022_C10 \
	PixelWifiOverlay2022_C10

PRODUCT_SOONG_NAMESPACES += device/google/pantah/cheetah/

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/pantah/prebuilts

# Location
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
        PRODUCT_COPY_FILES += \
                device/google/pantah/location/gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/gps.xml \
                device/google/pantah/location/lhd.conf:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/lhd.conf \
                device/google/pantah/location/scd.conf:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/scd.conf
else
        PRODUCT_COPY_FILES += \
                device/google/pantah/location/gps_user.xml:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/gps.xml \
                device/google/pantah/location/lhd_user.conf:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/lhd.conf \
                device/google/pantah/location/scd_user.conf:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/scd.conf
endif

# Set zram size
PRODUCT_VENDOR_PROPERTIES += \
	vendor.zram.size=3g

# Device features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml
