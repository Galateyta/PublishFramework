//
//  OvdWrapper.swift
//  ObjC-Project
//

import Foundation
import KTAKinegramEmrtdConnector
import SwiftUI
import CoreNFC
import UIKit
import CoreData

let EError_NFC_CLONED_CHIP:NSInteger = 910
let EError_NFC_SessionInvalidated:NSInteger = 1000
let EError_NFC_MoreThanOneTagFound:NSInteger = 1002
let EError_NFC_WrongTag:NSInteger = 1003
let EError_NFC_TagWasLost:NSInteger = 900
let EError_NFC_NotConnected:NSInteger = 901
let EError_NFC_MutualAuthenticationFailedNotSatisfied:NSInteger = 903
let EError_NFC_ReadFailed:NSInteger = 904
let EError_NFC_UnexpectedException:NSInteger = 905
let EError_NFC_Timeout:NSInteger = 906
let EError_NFC_TechnicalError:NSInteger = 909

extension NSNotification.Name {
    static let chipClonedDetectionResultNotificationName = Notification.Name(rawValue: "NfcChipClonedDetectionResult")
}

extension NSNotification.Name {
    static let chipClonedDetectionNotificationName = Notification.Name(rawValue: "NfcChipClonedDetectionCompleted")
}

extension NSNotification.Name {
    static let nfcStatusChangedNotificationName = Notification.Name(rawValue: "NfcStatusChanged")
}

struct AuthResult {
    static var nfcAuthCheckError: NSInteger = 0 {
        didSet {
            if nfcAuthCheckError != 0 {
                if #available(iOS 13.0, *) {
                    OvdWrapper.nfcAuthCheckError = nfcAuthCheckError
                }
                NotificationCenter.default.post(name: NSNotification.Name.chipClonedDetectionNotificationName, object: nil)
            }
        }
    }
    static var nfcStatus: String? = "" {
        didSet {
            if nfcStatus != "" {
                if #available(iOS 13.0, *) {
                    OvdWrapper.nfcStatus = nfcStatus!
                }
                NotificationCenter.default.post(name: NSNotification.Name.nfcStatusChangedNotificationName, object: nil)
            }
        }
    }
}

@available(iOS 13.0, *)
@objcMembers open class OvdWrapper : NSObject  {
    @objc public static var nfcAuthCheckError: NSInteger = 0
    @objc public static var nfcStatus: String? = ""
    @objc public var nfcErrorOptional: String? = ""
    @objc public var url = ""
    @objc public var saveAdditionalFiles: Bool  = true
    @objc public var saveAuthResult: Bool  = true
    @objc public var saveNfcResult : Bool = true
    @objc public var showProgress : Bool = false
    @objc public var nfcJson:[String:Any] = [:]
    @objc public var sodFileBinaryData:Data = Data()
    @objc public var dg1FileBinaryData:Data = Data()
    @objc public var dg2FileBinaryData:Data = Data()
    @objc public var dg3FileBinaryData:Data = Data()
    @objc public var dg4FileBinaryData:Data = Data()
    @objc public var dg5FileBinaryData:Data = Data()
    @objc public var dg6FileBinaryData:Data = Data()
    @objc public var dg7FileBinaryData:Data = Data()
    @objc public var dg8FileBinaryData:Data = Data()
    @objc public var dg9FileBinaryData:Data = Data()
    @objc public var dg10FileBinaryData:Data = Data()
    @objc public var dg11FileBinaryData:Data = Data()
    @objc public var dg12FileBinaryData:Data = Data()
    @objc public var dg13FileBinaryData:Data = Data()
    @objc public var dg14FileBinaryData:Data = Data()
    @objc public var dg15FileBinaryData:Data = Data()
    @objc public var dg16FileBinaryData:Data = Data()
    @objc public var activeAuthenticationResult:String?
    @objc public var chipAuthenticationResult:String?
    @objc public var sodInfo:[String:Any] = [:]
    @objc public var mrzInfo:[String:Any] = [:]
    @objc public var faceUIImage: UIImage? = UIImage()
    @objc public var hashForDataGroup:[String:String] = [:]
    @objc public var additionalPersonalDetails:[String:Any] = [:]
    @objc public var additionalDocumentDetails:[String:Any] = [:]
    @objc public var passiveAuthenticationDetails:[String:Any] = [:]
    @objc public var ovdConnectorWrapper:OvdConnectorWrapper = OvdConnectorWrapper()

    @objc public func initOvdWrapper(url:String,
                                     saveAdditionalFiles:Bool,
                                     saveAuthResult:Bool,
                                     saveNfcResult:Bool,
                                     showProgress:Bool)
    {
        self.url = url
        self.saveAdditionalFiles = saveAdditionalFiles
        self.saveAuthResult = saveAuthResult
        self.saveNfcResult = saveNfcResult
        self.showProgress = showProgress
    }

    @objc public func getAuthResult(passportNumber: String,
                                    dateOfBirth: String,
                                    dateOfExpiry: String,
                                    bundleId:String,
                                    processId:String)
    {
        NotificationCenter.default.addObserver(
           self,
           selector: #selector(self.chipClonedDetectionResult),
           name: NSNotification.Name.chipClonedDetectionResultNotificationName,
           object: nil)
        print("after ChipClonedDetectionNotificationName addObserver")
        ovdConnectorWrapper.textfieldPassportNumber = passportNumber
        ovdConnectorWrapper.textfieldDateOfBirth = dateOfBirth
        ovdConnectorWrapper.textfieldDateOfExpiry = dateOfExpiry
        ovdConnectorWrapper.getAuthenticationResult(passportNumber: passportNumber, dateOfBirth: dateOfBirth,
                                                    dateOfExpiry: dateOfExpiry, url: self.url,
                                                    showProgress: self.showProgress, processId: processId)
    }

    @objc public func resetNfcData()
    {
        OvdWrapper.nfcAuthCheckError = 0
        AuthResult.nfcAuthCheckError = 0
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func chipClonedDetectionResult(notification: NSNotification) {
        if (0 != OvdWrapper.nfcAuthCheckError)
        {
            print("Chip cloned detection error: \(OvdWrapper.nfcAuthCheckError)")
            return
        }

        print("chipClonedDetectionResult")
        if (self.saveAdditionalFiles) {
            print("saveAdditionalFiles is true")
            self.sodFileBinaryData = ovdConnectorWrapper.sodFileBinaryData
            self.dg1FileBinaryData = ovdConnectorWrapper.dg1FileBinaryData
            self.dg2FileBinaryData = ovdConnectorWrapper.dg2FileBinaryData
            self.dg3FileBinaryData = ovdConnectorWrapper.dg3FileBinaryData
            self.dg4FileBinaryData = ovdConnectorWrapper.dg4FileBinaryData
            self.dg5FileBinaryData = ovdConnectorWrapper.dg5FileBinaryData
            self.dg6FileBinaryData = ovdConnectorWrapper.dg6FileBinaryData
            self.dg7FileBinaryData = ovdConnectorWrapper.dg7FileBinaryData
            self.dg8FileBinaryData = ovdConnectorWrapper.dg8FileBinaryData
            self.dg9FileBinaryData = ovdConnectorWrapper.dg9FileBinaryData
            self.dg10FileBinaryData = ovdConnectorWrapper.dg10FileBinaryData
            self.dg11FileBinaryData = ovdConnectorWrapper.dg11FileBinaryData
            self.dg12FileBinaryData = ovdConnectorWrapper.dg12FileBinaryData
            self.dg13FileBinaryData = ovdConnectorWrapper.dg13FileBinaryData
            self.dg14FileBinaryData = ovdConnectorWrapper.dg14FileBinaryData
            self.dg15FileBinaryData = ovdConnectorWrapper.dg15FileBinaryData
            self.dg16FileBinaryData = ovdConnectorWrapper.dg16FileBinaryData
        }
        if (self.saveAuthResult) {
            print("saveAuthResult is true")
            self.activeAuthenticationResult = ovdConnectorWrapper.activeAuthenticationResult
            print(self.activeAuthenticationResult)
            self.chipAuthenticationResult = ovdConnectorWrapper.chipAuthenticationResult
            self.nfcJson["active_authentication_result"] = ovdConnectorWrapper.activeAuthenticationResult
            self.nfcJson["chip_authentication_result"] = ovdConnectorWrapper.chipAuthenticationResult
        }
        if (self.saveNfcResult) {
            print("saveNfcResult is true")
            parseSodInfo()
            parseMrzInfo()
            parseAdditionalPersonalDetails()
            parseAdditionalDocumentDetails()
            parsePassiveAuthenticationDetails()
            self.activeAuthenticationResult = ovdConnectorWrapper.activeAuthenticationResult
            print(self.activeAuthenticationResult)
            self.chipAuthenticationResult = ovdConnectorWrapper.chipAuthenticationResult
            self.faceUIImage = ovdConnectorWrapper.faceUIImage
        }
        NotificationCenter.default.post(name: NSNotification.Name.chipClonedDetectionNotificationName, object: nil)
    }

    @objc private func parseSodInfo() {
        var hashForDataGroupJson:[String:String] = [:]
        for (i,j) in ovdConnectorWrapper.sodInfo?.hashForDataGroup ?? [:]
        {
            hashForDataGroupJson.updateValue(j, forKey: String(i))
        }
        self.nfcJson["sod_info"] = ["hashAlgorithm":ovdConnectorWrapper.sodInfo?.hashAlgorithm ??
                                    "hashAlgorithm", "hashForDataGroup":hashForDataGroupJson]
        let dgPrefix = "dg"
        for (i,j) in ovdConnectorWrapper.sodInfo?.hashForDataGroup ?? [:]
        {
            hashForDataGroup.updateValue(j, forKey: dgPrefix + String(i))
        }
        self.sodInfo = ["hashAlgorithm":ovdConnectorWrapper.sodInfo?.hashAlgorithm ?? "hashAlgorithm",
                        "hashForDataGroup":hashForDataGroup]
    }

    private func dateFormatting(dateString:String?) -> String
    {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyMMdd"
        let date = inputFormatter.date(from: dateString ?? "")
        inputFormatter.dateFormat = "y-MM-dd"
        let dateResultString = inputFormatter.string(from: date!)
        return dateResultString
    }

    @objc private func parseMrzInfo() {
        self.mrzInfo = ["documentType":ovdConnectorWrapper.mrzInfo?.documentType ?? "nil",
                        "documentCode":ovdConnectorWrapper.mrzInfo?.documentCode ?? "nil",
                        "issuingState":ovdConnectorWrapper.mrzInfo?.issuingState ?? "nil",
                        "primaryIdentifier":ovdConnectorWrapper.mrzInfo?.primaryIdentifier ?? "nil",
                        "secondaryIdentifier":ovdConnectorWrapper.mrzInfo?.secondaryIdentifier ?? ["nil"],
                        "nationality":ovdConnectorWrapper.mrzInfo?.nationality ?? "nil",
                        "documentNumber":ovdConnectorWrapper.mrzInfo?.documentNumber ?? "nil",
                        "dateOfBirth":dateFormatting(dateString: ovdConnectorWrapper.mrzInfo?.dateOfBirth) ?? "nil",
                        "gender":ovdConnectorWrapper.mrzInfo?.gender ?? "nil",
                        "expirationDate":dateFormatting(dateString: ovdConnectorWrapper.mrzInfo?.dateOfExpiry) ?? "nil",
                        "optionalData1":ovdConnectorWrapper.mrzInfo?.optionalData1 ?? "nil",
                        "optionalData2":ovdConnectorWrapper.mrzInfo?.optionalData2 ?? "nil"
        ]
        self.nfcJson["mrz_info"] = self.mrzInfo
    }

    @objc private func parseAdditionalPersonalDetails() {
        self.additionalPersonalDetails = ["fullNameOfHolder":ovdConnectorWrapper.additionalPersonalDetails?.fullNameOfHolder ?? "nil",
                                          "otherNames":ovdConnectorWrapper.additionalPersonalDetails?.otherNames ?? [],
                                          "personalNumber":ovdConnectorWrapper.additionalPersonalDetails?.personalNumber ?? "nil",
                                          "fullDateOfBirth":ovdConnectorWrapper.additionalPersonalDetails?.fullDateOfBirth ?? "nil",
                                          "placeOfBirth":ovdConnectorWrapper.additionalPersonalDetails?.placeOfBirth ?? "nil",
                                          "permanentAddress":ovdConnectorWrapper.additionalPersonalDetails?.permanentAddress ?? "nil",
                                          "telephone":ovdConnectorWrapper.additionalPersonalDetails?.telephone ?? "nil",
                                          "profession":ovdConnectorWrapper.additionalPersonalDetails?.profession ?? "nil",
                                          "title":ovdConnectorWrapper.additionalPersonalDetails?.title ?? "nil",
                                          "personalSummary":ovdConnectorWrapper.additionalPersonalDetails?.personalSummary ?? "nil",
                                          "proofOfCitizenshipImage":ovdConnectorWrapper.additionalPersonalDetails?.proofOfCitizenshipImage ?? "nil",
                                          "otherValidTravelDocumentNumbers":ovdConnectorWrapper.additionalPersonalDetails?.otherValidTravelDocumentNumbers ?? "nil",
                                          "custodyInformation":ovdConnectorWrapper.additionalPersonalDetails?.custodyInformation ?? "nil"
        ]
        self.nfcJson["additional_personal_details"] = self.additionalPersonalDetails
    }

    @objc private func parseAdditionalDocumentDetails() {
        self.additionalDocumentDetails = ["issuingAuthority":ovdConnectorWrapper.additionalDocumentDetails?.issuingAuthority ?? "nil",
                                          "dateOfIssue":ovdConnectorWrapper.additionalDocumentDetails?.dateOfIssue ?? "nil",
                                          "namesOfOtherPersons":ovdConnectorWrapper.additionalDocumentDetails?.namesOfOtherPersons ?? "nil",
                                          "endorsementsAndObservations":ovdConnectorWrapper.additionalDocumentDetails?.endorsementsAndObservations ?? "nil",
                                          "taxOrExitRequirements":ovdConnectorWrapper.additionalDocumentDetails?.taxOrExitRequirements ?? "nil",
                                          "imageOfFront":ovdConnectorWrapper.additionalDocumentDetails?.imageOfFront ?? "nil",
                                          "imageOfRear":ovdConnectorWrapper.additionalDocumentDetails?.imageOfRear ?? "nil",
                                          "dateAndTimeOfPersonalization":ovdConnectorWrapper.additionalDocumentDetails?.dateAndTimeOfPersonalization ?? "nil",
                                          "personalizationSystemSerialNumber":ovdConnectorWrapper.additionalDocumentDetails?.personalizationSystemSerialNumber ?? "nil"
        ]
        self.nfcJson["additional_document_details"] = self.additionalDocumentDetails
    }

    @objc private func parsePassiveAuthenticationDetails() {
        self.passiveAuthenticationDetails = ["passiveAuthentication":ovdConnectorWrapper.passiveAuthentication ?? false,
                                          "sodSignatureValid":ovdConnectorWrapper.passiveAuthenticationDetails?.sodSignatureValid ?? "nil",
                                          "documentCertificateValid":ovdConnectorWrapper.passiveAuthenticationDetails?.documentCertificateValid ?? "nil",
                                          "dataGroupsChecked":ovdConnectorWrapper.passiveAuthenticationDetails?.dataGroupsChecked ?? "nil",
                                          "dataGroupsWithValidHash":ovdConnectorWrapper.passiveAuthenticationDetails?.dataGroupsWithValidHash ?? "nil",
                                          "error":ovdConnectorWrapper.passiveAuthenticationDetails?.error ?? "nil",
                                          "allHashesValid":ovdConnectorWrapper.passiveAuthenticationDetails?.allHashesValid ?? "nil"
        ]
        self.nfcJson["passive_authentication_details"] = self.passiveAuthenticationDetails
    }
}

extension String  {
   func localized() -> String {
       if String.getLanguage().isEmpty {
                   return NSLocalizedString(self, comment: "")
               }
               let path = Bundle.main.path(forResource: String.getLanguage(), ofType: "lproj")
               if path == nil {
                   return NSLocalizedString(self, comment: "")
               }
               let bundle = Bundle(path: path!)
               return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
           }
   static func getLanguage() -> String {
           if let currentISOLanguage = UserDefaults.standard.object(forKey: "CurrentISOLanguage") as? String {
               return currentISOLanguage.lowercased()
           } else if let currentLanguageCode = Locale.preferredLanguages.first?.split(separator: "-").first {
               if currentLanguageCode == "en" || currentLanguageCode == "de"   {
                   return String(currentLanguageCode)
               }
           }
           return "en"
       }
}

@available(iOS 13.0, *)
public class OvdConnectorWrapper : NSObject {
    private var url = ""
    private var processId = ""
    private var showProgress = false
    private var progressCounter = 0
    private let progressSteps = ["⬤◯◯◯◯◯◯", "⬤⬤◯◯◯◯◯", "⬤⬤⬤◯◯◯◯", "⬤⬤⬤⬤◯◯◯",
                                 "⬤⬤⬤⬤⬤◯◯", "⬤⬤⬤⬤⬤⬤◯", "⬤⬤⬤⬤⬤⬤⬤"]
    private let clientId = "FwpSx7LDS_Vd8YCT"
    public var connectorActiveAuthenticationResult: KTAKinegramEmrtdConnector.EmrtdPassport.CheckResult?
    public var connectorChipAuthenticationResult: KTAKinegramEmrtdConnector.EmrtdPassport.CheckResult?
    private var nfcReaderSession: NFCReaderSessionProtocol?
    public var textfieldPassportNumber:String = ""
    public var textfieldDateOfBirth:String = ""
    public var textfieldDateOfExpiry:String = ""
    public var emrtdConnector: EmrtdConnector? = nil
    public var emrtdPassport: KTAKinegramEmrtdConnector.EmrtdPassport?
    @objc var filesData: [String : Data]? = [:]
    @objc public var sodFileBinaryData:Data = Data()
    @objc public var dg1FileBinaryData:Data = Data()
    @objc public var dg2FileBinaryData:Data = Data()
    @objc public var dg3FileBinaryData:Data = Data()
    @objc public var dg4FileBinaryData:Data = Data()
    @objc public var dg5FileBinaryData:Data = Data()
    @objc public var dg6FileBinaryData:Data = Data()
    @objc public var dg7FileBinaryData:Data = Data()
    @objc public var dg8FileBinaryData:Data = Data()
    @objc public var dg9FileBinaryData:Data = Data()
    @objc public var dg10FileBinaryData:Data = Data()
    @objc public var dg11FileBinaryData:Data = Data()
    @objc public var dg12FileBinaryData:Data = Data()
    @objc public var dg13FileBinaryData:Data = Data()
    @objc public var dg14FileBinaryData:Data = Data()
    @objc public var dg15FileBinaryData:Data = Data()
    @objc public var dg16FileBinaryData:Data = Data()
    @objc public var faceUIImage: UIImage? = UIImage()
    @objc public var activeAuthenticationResult:String?
    @objc public var chipAuthenticationResult:String?
    public var sodInfo:KTAKinegramEmrtdConnector.EmrtdPassport.SODInfo?
    public var mrzInfo:KTAKinegramEmrtdConnector.EmrtdPassport.MRZInfo?
    public var additionalPersonalDetails:KTAKinegramEmrtdConnector.EmrtdPassport.AdditionalPersonalDetails?
    public var additionalDocumentDetails:KTAKinegramEmrtdConnector.EmrtdPassport.AdditionalDocumentDetails?
    public var passiveAuthentication:Bool?
    private var sessionInvalidationUserCanceled:Bool = false
    public var passiveAuthenticationDetails:KTAKinegramEmrtdConnector.EmrtdPassport.PassiveAuthenticationDetails?

    private func beginNFCSession() {
        self.nfcReaderSession?.invalidate()
        self.progressCounter = 0
        var session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: .main)
        session?.alertMessage = "Hold Passport to Phone".localized()
        session?.begin()
    }

    @objc public func getAuthenticationResult(passportNumber:String, dateOfBirth:String, dateOfExpiry:String, url:String, showProgress:Bool, processId:String) {
        print("getAuthenticationResult")
        self.textfieldPassportNumber = passportNumber
        self.textfieldDateOfBirth = dateOfBirth
        self.textfieldDateOfExpiry = dateOfExpiry
        self.url = url
        self.showProgress = showProgress
        self.processId = processId
        emrtdConnector = {
            EmrtdConnector(clientId: clientId, webSocketUrl: url, delegate: self)
        }()
        if !NFCTagReaderSession.readingAvailable {
            print("""
                NFCTagReaderSession reading not available!
                Have you configured your app to detect NFC Tags (Info.plist)?
                Have you added the capability "Near Field Communication Tag Reading"?
                Does this device support NFC?
                Does this device run iOS 13.0 or later?
                """)
        }
        if self.emrtdConnector == nil {
            print("EmrtdConnector not initialized.\n" +
            "Verify that the specified URL is correct.")
        }
        beginNFCSession()
    }

    @objc public func authDataParsing () {
        filesData = self.emrtdPassport?.filesBinary
        self.sodFileBinaryData = filesData?["sod"] ?? Data()
        self.dg1FileBinaryData = filesData?["dg1"] ?? Data()
        self.dg2FileBinaryData = filesData?["dg2"] ?? Data()
        self.dg3FileBinaryData = filesData?["dg3"] ?? Data()
        self.dg4FileBinaryData = filesData?["dg4"] ?? Data()
        self.dg5FileBinaryData = filesData?["dg5"] ?? Data()
        self.dg6FileBinaryData = filesData?["dg6"] ?? Data()
        self.dg7FileBinaryData = filesData?["dg7"] ?? Data()
        self.dg8FileBinaryData = filesData?["dg8"] ?? Data()
        self.dg9FileBinaryData = filesData?["dg9"] ?? Data()
        self.dg10FileBinaryData = filesData?["dg10"] ?? Data()
        self.dg11FileBinaryData = filesData?["dg11"] ?? Data()
        self.dg12FileBinaryData = filesData?["dg12"] ?? Data()
        self.dg13FileBinaryData = filesData?["dg13"] ?? Data()
        self.dg14FileBinaryData = filesData?["dg14"] ?? Data()
        self.dg15FileBinaryData = filesData?["dg15"] ?? Data()
        self.dg16FileBinaryData = filesData?["dg16"] ?? Data()
        if ((self.emrtdPassport?.passiveAuthentication) != nil) {
            print(" Data Integrity and Authenticity confirmed.")
            self.activeAuthenticationResult = self.emrtdPassport?.activeAuthenticationResult.rawValue
            self.chipAuthenticationResult = self.emrtdPassport?.chipAuthenticationResult.rawValue
            switch (self.connectorActiveAuthenticationResult, self.connectorChipAuthenticationResult) {
            case (.failed, _), (_, .failed):
                print("Chip is cloned.")
                AuthResult.nfcAuthCheckError = EError_NFC_CLONED_CHIP;
            case (.success, _), (_, .success):
                print("Chip is not cloned.")
            default:
                print("\n\nChip Clone-Detection is not supported by this eMRTD.")
            }
        } else {
            print(" Data Integrity and Authenticity not confirmed.")
            if let paDetails = self.emrtdPassport?.passiveAuthenticationDetails {
                print(paDetails.description)
            }
        }
        if !(self.emrtdPassport?.errors.isEmpty ?? false) {
            print(self.emrtdPassport?.errors)
        }
        self.sodInfo = self.emrtdPassport?.sodInfo
        self.mrzInfo = self.emrtdPassport?.mrzInfo
        self.faceUIImage = UIImage(data: self.emrtdPassport?.facePhoto ?? Data())
        self.additionalPersonalDetails = self.emrtdPassport?.additionalPersonalDetails
        self.additionalDocumentDetails = self.emrtdPassport?.additionalDocumentDetails
        self.passiveAuthentication = self.emrtdPassport?.passiveAuthentication
        self.passiveAuthenticationDetails = self.emrtdPassport?.passiveAuthenticationDetails
        NotificationCenter.default.post(name: NSNotification.Name.chipClonedDetectionResultNotificationName, object: nil)
    }
}

@available(iOS 13.0, *)
extension OvdConnectorWrapper: NFCTagReaderSessionDelegate {
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // NFC Reader Session is now active
        // It's useful to hold a reference to the NFC Reader Session
        self.nfcReaderSession = session
        sessionInvalidationUserCanceled = false
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        self.nfcReaderSession = nil
        if (error as? NFCReaderError)?.code == .readerSessionInvalidationErrorUserCanceled {
            sessionInvalidationUserCanceled = true
        } else {
            // Notify user about the error that occurred
            AuthResult.nfcAuthCheckError = EError_NFC_SessionInvalidated;
        }
    }

    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let emrtdConnector = self.emrtdConnector else {
            fatalError("EmrtdConnector unexpectedly nil")
        }
        guard tags.count == 1, let tag = tags.first else {
            session.invalidate(errorMessage: "More than one tag found")
            AuthResult.nfcAuthCheckError = EError_NFC_MoreThanOneTagFound;
            return
        }
        guard case let .iso7816(passportTag) = tag else {
            session.invalidate(errorMessage: "Non ISO7816 tag found")
            AuthResult.nfcAuthCheckError = EError_NFC_WrongTag;
            return
        }

        session.connect(to: tag) { error in
            guard error == nil else {
                session.invalidate(errorMessage: "Failed to connect to tag")
                return
            }
            // Successfully connected to the tag
            let dn = self.textfieldPassportNumber
            let dob = self.textfieldDateOfBirth
            let doe = self.textfieldDateOfExpiry
            emrtdConnector.connect(to: passportTag, vId: self.processId, documentNumber: dn,
                                       dateOfBirth: dob, dateOfExpiry: doe)
        }
    }
}

@available(iOS 13.0, *)
extension OvdConnectorWrapper: EmrtdConnectorDelegate {
    public func shouldRequestEmrtdPassport() -> Bool {
        return true
    }

    private func updateStatus(message: String, progress: String) {
        let newAlertMessage = (message + "\n" + progress).trimmingCharacters(in: .whitespacesAndNewlines)
        nfcReaderSession?.alertMessage = newAlertMessage
    }

    public func getProgress(status: EmrtdConnector.Status) -> String {
        // Update the message of the NFC reader session alert
        if !self.showProgress {
            return ""
        }
        let index = progressCounter < progressSteps.count - 1 ? progressCounter : progressSteps.count - 2
        var progressBar = ""
        switch status {
        case .readSOD, .chipAuthentication, .activeAuthentication, .readDG1, .readDG2, .readDG7, .readDG11,
                .readDG12, .readDG14, .readDG15, .passiveAuthentication, .accessControl:
            progressBar = progressSteps[index]
        case .done:
            progressBar = progressSteps[progressSteps.count - 1]
        default:
            progressBar = ""
        }
        if progressCounter < progressSteps.count - 1 {
            progressCounter += 1
        }
        return progressBar
    }

    public func getMessage(status: EmrtdConnector.Status) -> String {
        // Update the message of the NFC reader session alert
        switch status {
        case .readAtrInfo:
            return "Reading File Atr/Info".localized()
        case .connectingToServer:
            return "Connecting to Server".localized()
        case .accessControl:
            return "Performing Access Control".localized()
        case .readSOD:
            return "Reading File SOD".localized()
        case .chipAuthentication:
            return "Performing Chip Authentication".localized()
        case .activeAuthentication:
            return "Performing Active Authentication".localized()
        case .readDG1:
            return "Reading Data Group 1".localized()
        case .readDG2:
            return "Reading Data Group 2".localized()
        case .readDG7:
            return "Reading Data Group 7".localized()
        case .readDG11:
            return "Reading Data Group 11".localized()
        case .readDG12:
            return "Reading Data Group 12".localized()
        case .readDG14:
            return "Reading Data Group 14".localized()
        case .readDG15:
            return "Reading Data Group 15".localized()
        case .passiveAuthentication:
            return "Performing Passive Authentication".localized()
        case .done:
            return "Reading Done".localized()
        default:
            return ""
        }
    }

    public func emrtdConnector(_ emrtdConnector: EmrtdConnector,
                        didUpdateStatus status: EmrtdConnector.Status) {
        // Update the message of the NFC reader session alert
        switch status {
        case .readAtrInfo, .connectingToServer:
            updateStatus(message: getMessage(status: status), progress: "")
        case .readSOD, .chipAuthentication, .activeAuthentication, .readDG1, .readDG2, .readDG7, .readDG11, .readDG12,
                .readDG14, .readDG15, .passiveAuthentication, .accessControl:
            updateStatus(message: getMessage(status: status), progress: getProgress(status: status))
        case .done:
            print("NFC Reading Done")
            updateStatus(message: getMessage(status: status), progress: getProgress(status: status))
        default:
            return
        }
        AuthResult.nfcStatus = status.description
    }

    public func emrtdConnector(_ emrtdConnector: EmrtdConnector,
                        didReceiveEmrtdPassport emrtdPassport: KTAKinegramEmrtdConnector.EmrtdPassport?) {
        guard let emrtdPassport = emrtdPassport else {
           self.emrtdPassport = nil
           return
        }

        self.emrtdPassport = emrtdPassport
        authDataParsing()

    }

    public func emrtdConnector(_ emrtdConnector: EmrtdConnector,
                        didCloseWithCloseCode closeCode: Int,
                        reason: EmrtdConnector.CloseReason?) {
        let text = "\(closeCode) \(reason?.description ?? "")"
        print(text)
        if closeCode != 1_000 && !sessionInvalidationUserCanceled {
            switch reason {
            case .some(.timeoutWhileWaitingForStartMessage), .some(.timeoutWhileWaitingForResponse), .some(.maxSessionTimeExceeded):
                AuthResult.nfcAuthCheckError = EError_NFC_Timeout;
            case .some(.fileReadError):
                AuthResult.nfcAuthCheckError = EError_NFC_ReadFailed;
            case .some(.communicationFailed(_)), .some(.nfcChipCommunicationFailed(_)):
                AuthResult.nfcAuthCheckError = EError_NFC_NotConnected;
            case .some(.unexpectedMessage), .some(.invalidClientId), .some(.accessControlFailed), .some(.invalidStartMessage), .some(.serverError), .some(.postToResultServerFailed):
                AuthResult.nfcAuthCheckError = EError_NFC_TechnicalError;
            case .some(.invalidAccessKeyValues):
                AuthResult.nfcAuthCheckError = EError_NFC_MutualAuthenticationFailedNotSatisfied;
            case .some(.emrtdPassportReaderError):
                AuthResult.nfcAuthCheckError = EError_NFC_TagWasLost;
            case .none:
                AuthResult.nfcAuthCheckError = EError_NFC_UnexpectedException;
            case .some(_):
                AuthResult.nfcAuthCheckError = EError_NFC_UnexpectedException;
           }
            // To also show a message in the nfc dialog, call
            nfcReaderSession?.invalidate(errorMessage: "\(text.prefix(64))")
        }
    }
}
