//
// SPDX-FileCopyrightText: 2025 The LineageOS Project
// SPDX-License-Identifier: Apache-2.0
//

#pragma once

#include <stdint.h>
#include <string>

#define LOCKOUT_TIMED_THRESHOLD 5
#define LOCKOUT_TIMED_DURATION 10000
#define LOCKOUT_PERMANENT_THRESHOLD 20

namespace aidl::android::hardware::biometrics::fingerprint {

class LockoutTracker {
  public:
    LockoutTracker() : mFailedCount(0), mFailedCountTimed(0) {}
    ~LockoutTracker() {}

    enum class LockoutMode : int8_t { kNone = 0, kTimed, kPermanent };

    void reset(bool clearAttemptCounter);
    LockoutMode getMode();
    void addFailedAttempt();
    int64_t getLockoutTimeLeft();

  private:
    int32_t mFailedCount;
    int32_t mFailedCountTimed;
    int64_t mLockoutTimedStart;
    LockoutMode mCurrentMode;
};

}  // namespace aidl::android::hardware::biometrics::fingerprint
