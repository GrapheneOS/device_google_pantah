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

ifdef RELEASE_GOOGLE_CHEETAH_RADIO_DIR
RELEASE_GOOGLE_PRODUCT_RADIO_DIR := $(RELEASE_GOOGLE_CHEETAH_RADIO_DIR)
endif
RELEASE_GOOGLE_BOOTLOADER_CHEETAH_DIR ?= pdk# Keep this for pdk TODO: b/327119000
RELEASE_GOOGLE_PRODUCT_BOOTLOADER_DIR := bootloader/$(RELEASE_GOOGLE_BOOTLOADER_CHEETAH_DIR)
$(call soong_config_set,pantah_bootloader,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_CHEETAH_DIR))
ifneq ($(filter trunk%, $(RELEASE_GOOGLE_BOOTLOADER_CHEETAH_DIR)),)
$(call soong_config_set,pantah_fingerprint,prebuilt_dir,trunk)
else
$(call soong_config_set,pantah_fingerprint,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_CHEETAH_DIR))
endif


TARGET_LINUX_KERNEL_VERSION := $(RELEASE_KERNEL_CHEETAH_VERSION)
# Keeps flexibility for kasan and ufs builds
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_CHEETAH_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_CHEETAH_DIR)/kernel-headers

$(call inherit-product-if-exists, vendor/google_devices/pantah/prebuilts/device-vendor-cheetah.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs201/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs201/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/pantah/proprietary/cheetah/device-vendor-cheetah.mk)
$(call inherit-product-if-exists, vendor/google_devices/cheetah/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/pantah/proprietary/WallpapersCheetah.mk)

DEVICE_PACKAGE_OVERLAYS += device/google/pantah/cheetah/overlay

include device/google/gs201/device-shipping-common.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/syna/syna0.mk

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,cheetah)
$(call soong_config_set,lyric,tuning_product,cheetah)
$(call soong_config_set,google3a_config,target_device,cheetah)

# Init files
PRODUCT_COPY_FILES += \
	device/google/pantah/conf/init.pantah.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.pantah.rc \
	device/google/pantah/conf/init.cheetah.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.cheetah.rc

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/pantah/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.cheetah.rc

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st

# Shared Modem Platform
SHARED_MODEM_PLATFORM_VENDOR := lassen

# Shared Modem Platform
include device/google/gs-common/modem/modem_svc_sit/shared_modem_platform.mk

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element@1.2-service-gto \
	android.hardware.secure_element@1.2-service-gto-ese2

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml

DEVICE_MANIFEST_FILE += \
	device/google/pantah/nfc/manifest_se.xml

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio

PRODUCT_SOONG_NAMESPACES += device/google/pantah/cheetah/

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/pantah/prebuilts

# Location
PRODUCT_COPY_FILES += \
    device/google/pantah/location/lhd_user.conf.c10:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/lhd.conf \
    device/google/pantah/location/scd_user.conf.c10:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/scd.conf
ifneq (,$(filter 6.1, $(TARGET_LINUX_KERNEL_VERSION)))
    PRODUCT_COPY_FILES += \
        device/google/pantah/location/gps_user.6.1.xml.c10:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/gps.xml
else
    PRODUCT_COPY_FILES += \
        device/google/pantah/location/gps_user.xml.c10:$(TARGET_COPY_OUT_VENDOR)/etc/gnss/gps.xml
endif

PRODUCT_PACKAGES += \
    NoCutoutOverlay \
    AvoidAppsInCutoutOverlay

# SKU specific RROs
PRODUCT_PACKAGES += \
    SettingsOverlayGFE4J \
    SettingsOverlayGE2AE \
    SettingsOverlayGP4BC

# Vibrator HAL
$(call soong_config_set,haptics,kernel_ver,v$(subst .,_,$(TARGET_LINUX_KERNEL_VERSION)))
ACTUATOR_MODEL := luxshare_ict_081545
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1

# Device features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml

# Bluetooth device id
# Cheetah: 0x410A
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.device_id.product_id=16650

# ETM
ifneq (,$(RELEASE_ETM_IN_USERDEBUG_ENG))
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif
endif
