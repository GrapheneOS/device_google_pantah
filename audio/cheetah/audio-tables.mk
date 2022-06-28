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

AUDIO_TABLE_FOLDER := cheetah

# Platform Configuration for AudioHAL / SoundTriggerHAL
PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/audio_policy_configuration_bluetooth_legacy_hal.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration_bluetooth_legacy_hal.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/audio_policy_configuration_le_offload_disabled.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration_le_offload_disabled.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/audio_policy_configuration_a2dp_offload_disabled.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration_a2dp_offload_disabled.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/audio_platform_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_platform_configuration.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/sound_trigger_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sound_trigger_configuration.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/bluetooth_with_le_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_audio_policy_configuration_7_0.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml

# AudioEffectHAL Configuration
PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

# Mixer Path Configuration for AudioHAL
PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/config/mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/mixer_paths.xml

# Speaker firmware files
SPK_FIRMWARE_PATH := $(AUDIO_TABLE_FOLDER)/cs35l41/fw
SPK_FIRMWARE_FULL_PATH := device/google/pantah/audio/$(SPK_FIRMWARE_PATH)

PRODUCT_COPY_FILES += $(call copy-files,$(wildcard  $(SPK_FIRMWARE_FULL_PATH)/*),$(TARGET_COPY_OUT_VENDOR)/firmware)

# Audio tuning
PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/bluenote/recording.gatf:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/recording.gatf \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/BLUETOOTH.dat:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/BLUETOOTH.dat \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/HANDSFREE.dat:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/HANDSFREE.dat \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/HANDSET.dat:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/HANDSET.dat \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/HEADSET.dat:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/HEADSET.dat \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/mcps.dat:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/mcps.dat \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/waves/waves_config.ini:$(TARGET_COPY_OUT_VENDOR)/etc/waves_config.ini \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/waves/waves_preset.mps:$(TARGET_COPY_OUT_VENDOR)/etc/waves_preset.mps

# userdebug specific
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/BLUETOOTH.mods:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/BLUETOOTH.mods \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/HANDSFREE.mods:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/HANDSFREE.mods \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/HANDSET.mods:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/HANDSET.mods \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/fortemedia_stereo/HEADSET.mods:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/HEADSET.mods

#Bluenote files
PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/bluenote/template.xml:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/template.xml \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/bluenote/tuning_constraints_combination.xml:$(TARGET_COPY_OUT_VENDOR)/etc/aoc/tuning_constraints_combination.xml

# Mixer Path Configuration for Audio Speaker Calibration Tool crus_sp_cal
PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/cs35l41/crus_sp_cal_mixer_paths.xml:$(TARGET_COPY_OUT_VENDOR)/etc/crus_sp_cal_mixer_paths.xml

PRODUCT_COPY_FILES += \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/waves/tests/test_config.ini:$(TARGET_COPY_OUT_VENDOR)/etc/test_config.ini \
    device/google/pantah/audio/$(AUDIO_TABLE_FOLDER)/tuning/waves/tests/test_preset.mps:$(TARGET_COPY_OUT_VENDOR)/etc/test_preset.mps

endif
