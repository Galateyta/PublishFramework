#pragma once

#include "boost/property_tree/ptree.hpp"

#include <filesystem>
#include <optional>
#include <string>
#include <unordered_map>

#include "ConfigurationParser.h"
#include "Setting.h"

class ConfigurationParserXml final : public ConfigurationParser
{
  public:
    explicit ConfigurationParserXml(const std::filesystem::path& path);

    using BoolSettings = std::unordered_map<BoolSetting, bool>;
    BoolSettings loadBoolSettings() override;

    using StringSettings = std::unordered_map<StringSetting, std::string>;
    StringSettings loadStringSettings() override;

  protected:
    void loadFunctionalities(BoolSettings&) const;
    void loadFlags(BoolSettings&) const;
    void loadConfigs(StringSettings&) const;
    void loadModules(StringSettings&) const;

    boost::property_tree::ptree _xmlTree;

    static const std::unordered_map<std::string, BoolSetting> _functionalities;
    static const std::unordered_multimap<std::string, BoolSetting> _flags;
    static const std::unordered_map<std::string, StringSetting> _configs;
    static const std::unordered_map<std::string, StringSetting> _modules;
    static const std::string _mainNodeName;

    static std::optional<bool> string2bool(const std::string&);
    static std::string getOsName();

    static constexpr auto TAG = "[ConfigurationParserXml]";
};
