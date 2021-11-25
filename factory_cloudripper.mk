#
# Copyright 2021 The Android Open-Source Project
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

TARGET_LINUX_KERNEL_VERSION := 5.10

$(call inherit-product, device/google/gs201/factory_common.mk)
$(call inherit-product, device/google/pantah/device-cloudripper.mk)
include device/google/pantah/audio/cloudripper/factory-audio-tables.mk

PRODUCT_NAME := factory_cloudripper
PRODUCT_DEVICE := cloudripper
PRODUCT_MODEL := Factory build on Cloudripper
PRODUCT_BRAND := Android
PRODUCT_MANUFACTURER := Google

# default BDADDR for EVB only
PRODUCT_PROPERTY_OVERRIDES += \
	ro.vendor.bluetooth.evb_bdaddr="22:22:22:33:44:55"

# Factory binaries of camera
PRODUCT_PACKAGES += fatp_c10p10_wide_hat_tool fatp_c10_tele_hat_tool fatp_c10_ultrawide_hat_tool
