/*
 * Copyright (C) 2021 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define LOG_TAG "android.hardware.power.stats-service.pixel"

#include <dataproviders/DisplayStateResidencyDataProvider.h>
#include <dataproviders/PowerStatsEnergyConsumer.h>
#include <Gs201CommonDataProviders.h>
#include <PowerStatsAidl.h>

#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>
#include <log/log.h>
#include <sys/stat.h>

using aidl::android::hardware::power::stats::DisplayStateResidencyDataProvider;
using aidl::android::hardware::power::stats::EnergyConsumerType;
using aidl::android::hardware::power::stats::PowerStatsEnergyConsumer;

void addDisplay(std::shared_ptr<PowerStats> p) {
    // Add display residency stats
    std::vector<std::string> states = {
        "Off",
        "LP: 1080x2400@30",
        "On: 1080x2400@60",
        "On: 1080x2400@90",
        "HBM: 1080x2400@60",
        "HBM: 1080x2400@90"};

    p->addStateResidencyDataProvider(std::make_unique<DisplayStateResidencyDataProvider>(
            "Display",
            "/sys/class/backlight/panel0-backlight/state",
            states));

    // Add display energy consumer
    p->addEnergyConsumer(PowerStatsEnergyConsumer::createMeterAndEntityConsumer(
            p, EnergyConsumerType::DISPLAY, "display", {"VSYS_PWR_DISPLAY"}, "Display",
            {{"LP: 1080x2400@30", 1},
             {"On: 1080x2400@60", 2},
             {"On: 1080x2400@90", 3},
             {"HBM: 1080x2400@60", 4},
             {"HBM: 1080x2400@90", 5}}));
}

int main() {
    struct stat buffer;

    LOG(INFO) << "Pixel PowerStats HAL AIDL Service is starting.";

    // single thread
    ABinderProcess_setThreadPoolMaxThreadCount(0);

    std::shared_ptr<PowerStats> p = ndk::SharedRefBase::make<PowerStats>();

    addGs201CommonDataProviders(p);
    addDisplay(p);

    if (!stat("/sys/devices/platform/10970000.hsi2c/i2c-2/i2c-st21nfc/power_stats", &buffer)) {
        addNFC(p, "/sys/devices/platform/10970000.hsi2c/i2c-2/i2c-st21nfc/power_stats");
    } else if (!stat("/sys/devices/platform/10970000.hsi2c/i2c-3/i2c-st21nfc/power_stats", &buffer)) {
        addNFC(p, "/sys/devices/platform/10970000.hsi2c/i2c-3/i2c-st21nfc/power_stats");
    } else if (!stat("/sys/devices/platform/10970000.hsi2c/i2c-4/i2c-st21nfc/power_stats", &buffer)) {
        addNFC(p, "/sys/devices/platform/10970000.hsi2c/i2c-4/i2c-st21nfc/power_stats");
    } else if (!stat("/sys/devices/platform/10970000.hsi2c/i2c-5/i2c-st21nfc/power_stats", &buffer)) {
        addNFC(p, "/sys/devices/platform/10970000.hsi2c/i2c-5/i2c-st21nfc/power_stats");
    } else if (!stat("/sys/devices/platform/10970000.hsi2c/i2c-6/i2c-st21nfc/power_stats", &buffer)) {
        addNFC(p, "/sys/devices/platform/10970000.hsi2c/i2c-6/i2c-st21nfc/power_stats");
    } else if (!stat("/sys/devices/platform/10970000.hsi2c/i2c-7/i2c-st21nfc/power_stats", &buffer)) {
        addNFC(p, "/sys/devices/platform/10970000.hsi2c/i2c-7/i2c-st21nfc/power_stats");
    } else {
        addNFC(p, "/sys/devices/platform/10970000.hsi2c/i2c-8/i2c-st21nfc/power_stats");
    }
    const std::string instance = std::string() + PowerStats::descriptor + "/default";
    binder_status_t status = AServiceManager_addService(p->asBinder().get(), instance.c_str());
    LOG_ALWAYS_FATAL_IF(status != STATUS_OK);

    ABinderProcess_joinThreadPool();
    return EXIT_FAILURE;  // should not reach
}
