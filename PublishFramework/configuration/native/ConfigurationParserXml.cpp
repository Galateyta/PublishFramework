#include "ConfigurationParserXml.h"

#include "boost/algorithm/string.hpp"
#include "boost/property_tree/xml_parser.hpp"
#include "configuration.h"
#include <exception>
#include <iostream>
#include <unordered_set>

using namespace std::string_literals;

namespace
{
void logd(const std::string& str)
{
    std::cout << str;
}

void loge(const std::string& str)
{
    std::cerr << str;
}
} // namespace

const std::string ConfigurationParserXml::_mainNodeName = "skin";

const std::unordered_map<std::string, BoolSetting> ConfigurationParserXml::_functionalities = {
    { "1", BoolSetting::Barcode },   { "2", BoolSetting::IdScanner },
    { "3", BoolSetting::Document },  { "4", BoolSetting::Pdf },
    { "5", BoolSetting::Selfie },    { "6", BoolSetting::FaceVerification },
    { "7", BoolSetting::VideoCall }, { "8", BoolSetting::NfcReading },
    { "10", BoolSetting::Liveness }, { "11", BoolSetting::DocumentRecording }
};

const std::unordered_multimap<std::string, BoolSetting> ConfigurationParserXml::_flags{
    { "functionalityTracking", BoolSetting::FuncTracking },
    { "extendIdExpiration", BoolSetting::ExtendIdExpiration },
    { "functionalityTrackingToFile", BoolSetting::SaveMonitoringData },
    { "nfcServerEnabled", BoolSetting::NfcServerEnabled },
};

const std::unordered_map<std::string, StringSetting> ConfigurationParserXml::_configs = {
    { "sdkExpiration", StringSetting::SdkExpirationDate },
    { "brand", StringSetting::Brand },
    { "appName", StringSetting::AppName },
    { "xmlnsName", StringSetting::XmlHeader },
    { "savePath", StringSetting::SavePath },
    { "pubKeyPath", StringSetting::PublicKeyPath },
    { "monitoringUrl", StringSetting::MonitoringBaseUrl }
};

const std::unordered_map<std::string, StringSetting> ConfigurationParserXml::_modules = {
    { "modulePdf", StringSetting::PdfLicense }
};

ConfigurationParserXml::ConfigurationParserXml(const std::filesystem::path& path)
{
    if (!std::filesystem::exists(path))
    {
        throw std::runtime_error("Configuration path "s + path.string() + " does not exists"s);
    }

    try
    {
        boost::property_tree::read_xml(path.string(), _xmlTree);
    }
    catch (const boost::property_tree::xml_parser_error& error)
    {
        throw std::runtime_error("Configuration path "s + path.string() + " could not be read: "s + error.message());
    }
}

ConfigurationParserXml::BoolSettings ConfigurationParserXml::loadBoolSettings()
{
    BoolSettings boolSettings;
    loadFlags(boolSettings);
    loadFunctionalities(boolSettings);
    return boolSettings;
}

ConfigurationParserXml::StringSettings ConfigurationParserXml::loadStringSettings()
{
    StringSettings stringSettings;
    loadConfigs(stringSettings);
    loadModules(stringSettings);
    return stringSettings;
}

void ConfigurationParserXml::loadFunctionalities(BoolSettings& boolSettings) const
{
    const auto functionalitiesValueMobile =
        _xmlTree.get_optional<std::string>(_mainNodeName + "."s + "functionalityList");
    const auto functionalitiesValueWeb =
        _xmlTree.get_optional<std::string>(_mainNodeName + "."s + "functionalityListWeb");
    if (!functionalitiesValueMobile && !functionalitiesValueWeb)
    {
        throw std::runtime_error("<"s + "functionalityList" + "> tag missing in description.xml"s);
    }

    std::vector<std::string> functionalities;
    std::vector<std::string> functionalitiesMobile;
    std::vector<std::string> functionalitiesWeb;

    if (functionalitiesValueMobile)
    {
        boost::split(functionalitiesMobile, *functionalitiesValueMobile, [](auto ch) { return ch == ','; });
        functionalities = functionalitiesMobile;
    }

    if (functionalitiesValueWeb)
    {
        boost::split(functionalitiesWeb, *functionalitiesValueWeb, [](auto ch) { return ch == ','; });
        if (functionalitiesValueMobile)
        {
            functionalities.insert(functionalities.end(), functionalitiesWeb.begin(), functionalitiesWeb.end());
        }
        else
        {
            functionalities = functionalitiesWeb;
        }
    }

    for (const auto& fun : functionalities)
    {
        const auto funTrimmed = boost::trim_copy(fun);
        if (_functionalities.find(funTrimmed) == _functionalities.end())
        {
            loge("Unknown functionality: " + funTrimmed);
            continue;
        }
        const auto setting = _functionalities.at(funTrimmed);
        boolSettings[setting] = true;
    }
}

void ConfigurationParserXml::loadFlags(BoolSettings& boolSettings) const
{
    for (const auto& flag : _flags)
    {
        const auto& nameXml = flag.first;
        const auto& nameConfig = flag.second;

        const auto setting = _xmlTree.get_optional<std::string>(_mainNodeName + "."s + nameXml);
        if (!setting)
        {
            logd("<" + nameXml + "> tag missing in description.xml");
            continue;
        }

        const auto boolSetting = string2bool(*setting);
        if (!boolSetting)
        {
            logd("Unsupported value " + *setting + " of <" + nameXml + "> tag in description.xml");
            continue;
        }

        boolSettings[nameConfig] = *boolSetting;
    }
}

void ConfigurationParserXml::loadConfigs(StringSettings& stringSettings) const
{
    for (const auto& config : _configs)
    {
        const auto& nameXml = config.first;
        const auto& nameConfig = config.second;

        const auto setting = _xmlTree.get_optional<std::string>(_mainNodeName + "."s + nameXml);
        if (!setting)
        {
            logd("<" + nameXml + "> tag missing in description.xml");
            continue;
        }
        stringSettings[nameConfig] = boost::trim_copy(*setting);
    }
}

void ConfigurationParserXml::loadModules(StringSettings& stringSettings) const
{
    for (const auto& module : _modules)
    {
        const auto& nameXml = module.first;
        const auto& nameConfig = module.second;

        const auto licenseNodeName = _mainNodeName + "."s + nameXml + ".license."s + getOsName();
        const auto licenseNodes = _xmlTree.get_child_optional(licenseNodeName);
        if (!licenseNodes || licenseNodes->empty())
        {
            continue;
        }

        std::string setting;
        for (const auto& key : *licenseNodes)
        {
            const auto node = key.second;
            const auto id = node.get_optional<std::string>("<xmlattr>.id");
            if (!id)
            {
                logd("Missing id for <" + nameXml + " > module key in description.xml");
                continue;
            }

            const auto license = node.get<std::string>("");
            setting += *id + " "s + license + " "s;
        }
        boost::trim(setting);
        stringSettings[nameConfig] = setting;
    }
}

std::optional<bool> ConfigurationParserXml::string2bool(const std::string& s)
{
    static const std::unordered_set<std::string> trueValues = { "on", "1", "yes", "true" };
    static const std::unordered_set<std::string> falseValues = { "off", "0", "no", "false" };

    auto s_lower = boost::to_lower_copy(s);
    boost::trim(s_lower);

    if (trueValues.find(s_lower) != trueValues.end())
    {
        return true;
    }
    if (falseValues.find(s_lower) != falseValues.end())
    {
        return false;
    }
    return {};
}

std::string ConfigurationParserXml::getOsName()
{
#if defined __ANDROID__ || defined _ANDROID
    return "android";
#elif defined __APPLE__
    return "iOS";
#elif defined _WIN32 || defined _WIN64
    return "windows";
#elif defined __linux__
    return "linux";
#elif defined EMSCRIPTEN
    return "emscripten";
#else
    static_assert(false, "unknown platform");
#endif
}
