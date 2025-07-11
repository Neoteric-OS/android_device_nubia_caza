/*
 * SPDX-FileCopyrightText: 2024 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include "Fingerprint.h"

#include <android-base/logging.h>

namespace aidl::android::hardware::biometrics::fingerprint {

namespace {
constexpr size_t MAX_WORKER_QUEUE_SIZE = 5;
constexpr int MAX_ENROLLMENTS_PER_USER = 7;
constexpr char HW_COMPONENT_ID[] = "fingerprintSensor";
constexpr char HW_VERSION[] = "vendor/model/revision";
constexpr char FW_VERSION[] = "1.01";
constexpr char SERIAL_NUMBER[] = "00000001";
constexpr char SW_COMPONENT_ID[] = "matchingAlgorithm";
constexpr char SW_VERSION[] = "vendor/version/revision";
}  // namespace

Fingerprint::Fingerprint() : mWorker(MAX_WORKER_QUEUE_SIZE) {
    mEngine = std::make_unique<FingerprintEngine>();
}

ndk::ScopedAStatus Fingerprint::getSensorProps(std::vector<SensorProps>* out) {
    std::vector<common::ComponentInfo> componentInfo = {
            {HW_COMPONENT_ID, HW_VERSION, FW_VERSION, SERIAL_NUMBER, "" /* softwareVersion */},
            {SW_COMPONENT_ID, "" /* hardwareVersion */, "" /* firmwareVersion */,
             "" /* serialNumber */, SW_VERSION}};

    common::CommonProps commonProps = {0, common::SensorStrength::STRONG, MAX_ENROLLMENTS_PER_USER,
                                       componentInfo};

    *out = {{
            commonProps,
            FingerprintSensorType::UNDER_DISPLAY_OPTICAL,
            {{
                    .sensorLocationX = 558,
                    .sensorLocationY = 1848,
                    .sensorRadius = 107,
            }},
            false /* supportsNavigationGestures */,
            false /* supportsDetectInteraction */,
            false /* halHandlesDisplayTouches */,
            true /* halControlsIllumination */,
            std::nullopt,
    }};

    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Fingerprint::createSession(int32_t /*sensorId*/, int32_t userId,
                                              const std::shared_ptr<ISessionCallback>& cb,
                                              std::shared_ptr<ISession>* out) {
    CHECK(mSession == nullptr || mSession->isClosed()) << "Open session already exists!";

    mSession = SharedRefBase::make<Session>(userId, cb, mEngine.get(), &mWorker);
    *out = mSession;

    mSession->linkToDeath(cb->asBinder().get());

    return ndk::ScopedAStatus::ok();
}

}  // namespace aidl::android::hardware::biometrics::fingerprint
