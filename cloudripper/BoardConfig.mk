#
# Copyright (C) 2020 The Android Open-Source Project
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
TARGET_BOARD_INFO_FILE := device/google/pantah/board-info.txt
TARGET_BOOTLOADER_BOARD_NAME := cloudripper
TARGET_SCREEN_DENSITY := 440
BOARD_USES_GENERIC_AUDIO := true
USES_DEVICE_GOOGLE_CLOUDRIPPER := true

include device/google/gs201/BoardConfig-common.mk
-include vendor/google_devices/gs201/prebuilts/BoardConfigVendor.mk
include device/google/gs-common/check_current_prebuilt/check_current_prebuilt.mk
include device/google/pantah-sepolicy/cloudripper-sepolicy.mk
include device/google/pantah/wifi/BoardConfig-wifi.mk
