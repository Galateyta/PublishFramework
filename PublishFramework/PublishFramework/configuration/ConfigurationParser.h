#pragma once
#include "Setting.h"
#include <string>
#include <unordered_map>

class ConfigurationParser
{
  public:
    virtual std::unordered_map<BoolSetting, bool> loadBoolSettings() = 0;
    virtual std::unordered_map<StringSetting, std::string> loadStringSettings() = 0;

    virtual ~ConfigurationParser()
    {
    }
};
