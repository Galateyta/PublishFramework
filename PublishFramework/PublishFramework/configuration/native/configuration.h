#pragma once

#include "Setting.h"
#include <filesystem>
#include <string>
#include <unordered_map>

#ifdef _MSC_VER
#define SECURITY_FORCE_INLINE __forceinline
#else
#define SECURITY_FORCE_INLINE __attribute((always_inline)) inline
#endif

class Configuration
{
  public:
    void loadConfiguration(const std::filesystem::path& path);
    void reset();

    /*
     * Typical usage: if (config.getSetting(LIVENESS, value) && value) {...}
     */
    SECURITY_FORCE_INLINE bool getSetting(BoolSetting set, bool& out) const
    {
        const auto iter = _boolSettings.find(set);
        if (iter != _boolSettings.cend())
        {
            out = iter->second;
            return true;
        }
        return false;
    }

    /*
     * Typical usage: if (config.getSetting(LIVENESS)) {...}
     * Note: does not differentiate between missing configuration and false!
     */
    SECURITY_FORCE_INLINE bool getSetting(BoolSetting set) const
    {
        if (_boolSettings.contains(set))
        {
            return _boolSettings.at(set);
        }
        else
        {
            return false;
        }
    }

    /*
     * Typical usage: if (config.getSetting(APP_NAME, value) && value == expectedValue) {...}
     */
    SECURITY_FORCE_INLINE bool getSetting(StringSetting set, std::string& out) const
    {
        const auto iter = _stringSettings.find(set);
        if (iter != _stringSettings.cend())
        {
            out = iter->second;
            return true;
        }
        return false;
    }

  protected:
    std::unordered_map<BoolSetting, bool> _boolSettings;
    std::unordered_map<StringSetting, std::string> _stringSettings;

  private:
    SECURITY_FORCE_INLINE void addBoolSetting(BoolSetting set, bool value)
    {
        const auto iter = _boolSettings.find(set);
        if (iter != _boolSettings.cend())
        {
            iter->second = value;
            return;
        }

        _boolSettings.emplace(set, value);
    }
};

Configuration& GetGlobalConfiguration();

// This is a macro to make it embed in the caller code and be harder to bypass
#define SECURITY_CHECK_TRUE(setting)                                                                                   \
    {                                                                                                                  \
        bool securityBoolSet = false;                                                                                  \
        if (!GetGlobalConfiguration().getSetting(setting, securityBoolSet) || !securityBoolSet)                        \
        {                                                                                                              \
            exit(77); /* EX_NOPERM error code */                                                                       \
        }                                                                                                              \
    }
