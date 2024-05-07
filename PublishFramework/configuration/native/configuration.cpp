#include "configuration.h"
#include "ConfigurationParserXml.h"
#include "LicenseChecker.h"

#include <filesystem>

namespace fs = std::filesystem;

namespace
{
static Configuration _config;
}

Configuration& GetGlobalConfiguration()
{
    return _config;
}

void Configuration::loadConfiguration(const fs::path& path)
{
    if (LicenseChecker::verifyLicense(path))
    {
        ConfigurationParserXml parser(path);
        _boolSettings = parser.loadBoolSettings();
        _stringSettings = parser.loadStringSettings();
    }
    else
    {
        throw std::runtime_error("Unable to load configuration file!");
    }
}

void Configuration::reset()
{
    _boolSettings.clear();
    _stringSettings.clear();
}
