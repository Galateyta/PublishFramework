#pragma once

#include <array>
#include <filesystem>
#include <string>
#include <vector>

namespace fs = std::filesystem;
class LicenseChecker
{
  public:
    static bool verifyLicense(const fs::path& configPath);
    static void generateLicense(const fs::path& configPath, const std::string& author, const std::string& customer,
                                const std::string& privateKey);

  protected:
    static std::vector<unsigned char> generateSignature(const std::vector<unsigned char>& buffer,
                                                        const std::string& privateKey);
    static bool verifySignature(const std::vector<unsigned char>& buffer, const std::vector<unsigned char>& signature,
                                const std::string& publicKey);

    static std::string toHexString(const std::array<unsigned char, 32>& buffer);
    static std::array<unsigned char, 32> sha256(const std::vector<unsigned char>& buffer);
    static std::vector<unsigned char> loadFile(const fs::path& path);
};
