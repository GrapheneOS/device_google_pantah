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

# WiFi
BOARD_WLAN_DEVICE := bcmdhd
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_bcmdhd
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
# Wifi interface combination - {1 STA + 1 AP} or {1 STA + 1 AP_BRIDGED} or {1 STA + 1 P2P}
# or {1 STA + 1 NAN} or {2 STA}
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 1}, {{P2P, NAN, AP, AP_BRIDGED}, 1}}, {{{STA}, 2}}
WIFI_FEATURE_WIFI_EXT_HAL := true
WIFI_FEATURE_IMU_DETECTION := true
# Avoid Wifi reset on MAC Address change
WIFI_AVOID_IFACE_RESET_MAC_CHANGE := true
WIFI_FEATURE_HOSTAPD_11AX := true
BOARD_HOSTAPD_CONFIG_80211W_MFP_OPTIONAL := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true

PRODUCT_COPY_FILES += \
    device/google/pantah/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    device/google/pantah/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

# Add WIFI_FEATURE_IMU_DETECTION to soong_config
$(call soong_config_set,wifi,feature_imu_detection,$(WIFI_FEATURE_IMU_DETECTION))
