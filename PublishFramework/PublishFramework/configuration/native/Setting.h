#pragma once

enum class BoolSetting
{
    Barcode,
    IdScanner,
    Document,
    Pdf,
    Selfie,
    FaceVerification,
    DocumentRecording,
    VideoCall,
    NfcReading,
    Liveness,
    FuncTracking,
    ExtendIdExpiration,
    SaveMonitoringData,
    NfcServerEnabled,
};

enum class StringSetting
{
    Brand,
    AppName,
    XmlHeader,
    PdfLicense,
    SavePath,
    SdkExpirationDate,
    MonitoringBaseUrl,
    PublicKeyPath
};
