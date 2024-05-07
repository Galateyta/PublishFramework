// disable warnings on MSVC
#define _CRT_SECURE_NO_WARNINGS

#include "LicenseChecker.h"
#include "LicensePublicKey.h"

#include <boost/algorithm/string.hpp>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <openssl/rsa.h>
#include <openssl/sha.h>

#include <array>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <ostream>
#include <sstream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

namespace
{
const std::string newline = "\n";

void logd(const std::string& str)
{
    std::cout << str;
}

void loge(const std::string& str)
{
    std::cerr << str;
}
} // namespace

void LicenseChecker::generateLicense(const fs::path& configPath, const std::string& author, const std::string& customer,
                                     const std::string& privateKey)
{
    const auto xmlHexDigest = toHexString(sha256(loadFile(configPath)));

    const auto dir = configPath.parent_path();
    const auto licensePath = dir / "license.txt";
    const auto signaturePath = dir / "license.sig";

    const auto now = std::chrono::system_clock::now();

    const std::time_t t = std::chrono::system_clock::to_time_t(now);
    const auto utcDate = std::to_string(t);

    logd("generateLicense: " + licensePath.string() + " - " + utcDate);

    {
        std::ofstream licenseFile;
        licenseFile.open(licensePath.string(), std::ios::binary);
        licenseFile << author << newline;
        licenseFile << customer << newline;
        licenseFile << utcDate << newline;
        licenseFile << xmlHexDigest << newline;
        licenseFile.flush();
        licenseFile.close();
    }

    const auto licenseBuffer = loadFile(licensePath);
    const auto signature = generateSignature(licenseBuffer, privateKey);

    std::ofstream signatureFile;
    signatureFile.open(signaturePath.string(), std::ios::binary);
    signatureFile.write(reinterpret_cast<const char*>(signature.data()), signature.size());
    signatureFile.close();
}

bool LicenseChecker::verifyLicense(const fs::path& configPath)
{
    const auto xmlHexDigest = toHexString(sha256(loadFile(configPath)));

    const auto dir = configPath.parent_path();
    const auto licensePath = dir / "license.txt";
    const auto signaturePath = dir / "license.sig";

    logd("verifyLicense: " + licensePath.string());
    if (!std::filesystem::exists(licensePath))
    {
        loge("Failed to find license.");
        return false;
    }

    // check that sha256 from license.bin matches path's sha256
    const auto licenseBuffer = loadFile(licensePath);
    const std::string licenseStr(licenseBuffer.begin(), licenseBuffer.end());
    std::vector<std::string> licenseLines;
    boost::split(licenseLines, licenseStr, boost::is_any_of(newline));
    while (licenseLines.size() > 0 && licenseLines.back().size() < 64)
    {
        licenseLines.pop_back();
    }
    bool descriptionHashMatches = licenseLines.size() > 0 && licenseLines.back() == xmlHexDigest;

    // check that signature decrypts with public key to sha256 of license.bin
    const auto signatureBuffer = loadFile(signaturePath);
    bool signatureMatches = true;
    // Added check to prevent the crash on iOS when PDF is enabled
#if not defined __APPLE__ || not defined PDF
    signatureMatches = verifySignature(licenseBuffer, signatureBuffer, ::rsaPublicKeyFormatted);
#endif
    const auto result = descriptionHashMatches && signatureMatches;
    if (!result)
    {
        const auto msg1 = descriptionHashMatches ? "success" : "failure";
        const auto msg2 = signatureMatches ? "success" : "failure";
        loge("Licence verification failed!\n  Description hash match: " + std::string{ msg1 }
             + "\n  Signature match: " + std::string{ msg2 });
    }

    return result;
}

std::vector<unsigned char> LicenseChecker::generateSignature(const std::vector<unsigned char>& buffer,
                                                             const std::string& privateKeyStr)
{
    BIO* rsaPrivateBIO = BIO_new_mem_buf(privateKeyStr.c_str(), static_cast<int>(privateKeyStr.size()));

    RSA* rsaPrivateKey = RSA_new();
    if (PEM_read_bio_RSAPrivateKey(rsaPrivateBIO, &rsaPrivateKey, nullptr, nullptr) == nullptr)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("generateSignature PEM_read_bio_RSAPrivateKey: " + std::string{ errorString.data() });
        RSA_free(rsaPrivateKey);
        BIO_free(rsaPrivateBIO);
        ERR_clear_error();
        return {};
    }

    EVP_PKEY* privateKey = EVP_PKEY_new();
    if (privateKey == nullptr)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("generateSignature EVP_PKEY_new: " + std::string{ errorString.data() });
        EVP_PKEY_free(privateKey);
        RSA_free(rsaPrivateKey);
        BIO_free(rsaPrivateBIO);
        ERR_clear_error();
        return {};
    }

    EVP_PKEY_assign_RSA(privateKey, rsaPrivateKey);
    EVP_MD_CTX* ctx = EVP_MD_CTX_create();
    EVP_MD_CTX_init(ctx);
    if (ctx == nullptr)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("generateSignature EVP_MD_CTX_create: " + std::string{ errorString.data() });
        EVP_MD_CTX_destroy(ctx);
        EVP_PKEY_free(privateKey);
        BIO_free(rsaPrivateBIO);
        ERR_clear_error();
        return {};
    }

    std::vector<unsigned char> signature(100000, 0);

    if (EVP_DigestSignInit(ctx, nullptr, EVP_sha256(), nullptr, privateKey) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("generateSignature EVP_DigestSignInit: " + std::string{ errorString.data() });
        EVP_MD_CTX_destroy(ctx);
        EVP_PKEY_free(privateKey);
        BIO_free(rsaPrivateBIO);
        ERR_clear_error();
        return {};
    }

    if (EVP_DigestSignUpdate(ctx, buffer.data(), buffer.size()) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("generateSignature EVP_DigestSignUpdate: " + std::string{ errorString.data() }
             + "\n    buffer.size: " + std::to_string(buffer.size()));
        EVP_MD_CTX_destroy(ctx);
        EVP_PKEY_free(privateKey);
        BIO_free(rsaPrivateBIO);
        ERR_clear_error();
        return {};
    }
    size_t signatureSize = signature.size();
    if (EVP_DigestSignFinal(ctx, signature.data(), &signatureSize) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("generateSignature EVP_DigestSignFinal: " + std::string{ errorString.data() }
             + "\n    signature size: " + std::to_string(signatureSize));
        EVP_MD_CTX_destroy(ctx);
        EVP_PKEY_free(privateKey);
        BIO_free(rsaPrivateBIO);
        ERR_clear_error();
        return {};
    }

    EVP_MD_CTX_destroy(ctx);
    EVP_PKEY_free(privateKey);
    BIO_free(rsaPrivateBIO);
    ERR_clear_error();

    signature.resize(signatureSize);
    logd("signatureSize: " + std::to_string(signature.size()));
    return signature;
}

bool LicenseChecker::verifySignature(const std::vector<unsigned char>& buffer,
                                     const std::vector<unsigned char>& signature, const std::string& publicKeyStr)
{
    BIO* rsaPublicBIO = BIO_new_mem_buf(publicKeyStr.c_str(), static_cast<int>(publicKeyStr.size()));

    RSA* rsaPublicKey = RSA_new();
    if (PEM_read_bio_RSA_PUBKEY(rsaPublicBIO, &rsaPublicKey, nullptr, nullptr) == nullptr)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("verifySignature PEM_read_bio_RSAPublicKey: " + std::string{ errorString.data() }
             + "\n    public key: " + publicKeyStr);
        RSA_free(rsaPublicKey);
        BIO_free(rsaPublicBIO);
        ERR_clear_error();
        return false;
    }

    EVP_PKEY* publicKey = EVP_PKEY_new();
    EVP_PKEY_assign_RSA(publicKey, rsaPublicKey);
    EVP_MD_CTX* ctx = EVP_MD_CTX_create();
    EVP_MD_CTX_init(ctx);
    if (EVP_DigestVerifyInit(ctx, nullptr, EVP_sha256(), nullptr, publicKey) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("verifySignature EVP_DigestVerifyInit: " + std::string{ errorString.data() });
        EVP_MD_CTX_destroy(ctx);
        EVP_PKEY_free(publicKey);
        BIO_free(rsaPublicBIO);
        ERR_clear_error();
        return {};
    }
    if (EVP_DigestVerifyUpdate(ctx, buffer.data(), buffer.size()) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("verifySignature EVP_DigestVerifyUpdate: " + std::string{ errorString.data() }
             + "\n    buffer.size: " + std::to_string(buffer.size()));
        EVP_MD_CTX_destroy(ctx);
        EVP_PKEY_free(publicKey);
        BIO_free(rsaPublicBIO);
        ERR_clear_error();
        return {};
    }
    int verifyFinal = EVP_DigestVerifyFinal(ctx, signature.data(), signature.size());
    if (0 == verifyFinal)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("verifySignature EVP_DigestVerifyFinal: " + std::string{ errorString.data() }
             + "\n    signature.size: " + std::to_string(signature.size()));
        EVP_MD_CTX_destroy(ctx);
        EVP_PKEY_free(publicKey);
        BIO_free(rsaPublicBIO);
        ERR_clear_error();
        return {};
    }

    EVP_MD_CTX_destroy(ctx);
    EVP_PKEY_free(publicKey);
    BIO_free(rsaPublicBIO);
    ERR_clear_error();

    return verifyFinal == 1;
}

std::string LicenseChecker::toHexString(const std::array<unsigned char, 32>& buffer)
{
    std::ostringstream hexStream;
    hexStream << std::hex;
    for (auto c : buffer)
    {
        hexStream << std::setw(2) << std::setfill('0') << (int)c;
    }

    return hexStream.str();
}

std::array<unsigned char, 32> LicenseChecker::sha256(const std::vector<unsigned char>& buffer)
{
    std::array<unsigned char, 32> digest{};

    EVP_MD_CTX* ctx = EVP_MD_CTX_create();
    EVP_MD_CTX_init(ctx);
    if (EVP_DigestInit(ctx, EVP_sha256()) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("sha256 EVP_DigestInit: " + std::string{ errorString.data() });
        EVP_MD_CTX_destroy(ctx);
        return digest;
    }

    if (EVP_DigestUpdate(ctx, buffer.data(), buffer.size()) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("sha256 EVP_DigestUpdate: " + std::string{ errorString.data() });
        EVP_MD_CTX_destroy(ctx);
        return digest;
    }

    unsigned int digestSize = static_cast<unsigned int>(digest.size());
    if (EVP_DigestFinal(ctx, digest.data(), &digestSize) == 0)
    {
        std::array<char, 120> errorString{};
        ERR_error_string(ERR_get_error(), errorString.data());
        loge("sha256 EVP_DigestFinal: " + std::string{ errorString.data() });
        EVP_MD_CTX_destroy(ctx);
        return digest;
    }

    EVP_MD_CTX_destroy(ctx);

    if (digestSize != digest.size())
    {
        loge("sha256 digest wrong size: " + std::to_string(digestSize) + " vs. expected "
             + std::to_string(digest.size()));
    }

    return digest;
}

std::vector<unsigned char> LicenseChecker::loadFile(const fs::path& path)
{
    if (!fs::exists(path))
    {
        loge("loadFile missing: " + path.string());
        return {};
    }

    std::ifstream file(path.string(), std::ios::binary | std::ios::ate);
    std::streamsize size = file.tellg();
    file.seekg(0, std::ios::beg);
    std::vector<unsigned char> buffer(size, 0);
    file.read(reinterpret_cast<char*>(buffer.data()), buffer.size());
    return buffer;
}
