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

# UWB - ultra wide band
$(call inherit-product-if-exists, vendor/qorvo/uwb/uwb.mk)

LOCAL_UWB_CAL_DIR=device/google/pantah/uwb

PRODUCT_COPY_FILES += \
    $(LOCAL_UWB_CAL_DIR)/UWB-calibration-restricted.conf:$(TARGET_COPY_OUT_VENDOR)/etc/uwb/UWB-calibration-unknown.conf \
    $(LOCAL_UWB_CAL_DIR)/UWB-calibration-default.conf:$(TARGET_COPY_OUT_VENDOR)/etc/uwb/UWB-calibration-default.conf \
    $(LOCAL_UWB_CAL_DIR)/UWB-calibration.conf:$(TARGET_COPY_OUT_VENDOR)/etc/uwb/UWB-calibration.conf \
    $(LOCAL_UWB_CAL_DIR)/init.uwb.calib.xtal.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.uwb.calib.sh \

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.uwb.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.uwb.xml

