
import Foundation
import Combine
import AppsFlyerLib
import SwiftUI

    extension CorvenfallUpdateManager {
    
        @MainActor public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
            let debugLocal = Int.random(in: 1...100)
            print("appsFl succes ->: \(debugLocal)")
            
            let rawData   = try! JSONSerialization.data(withJSONObject: conversionInfo, options: .fragmentsAllowed)
            let rawString = String(data: rawData, encoding: .utf8) ?? "{}"
            
            let finalJson = """
        {
            "\(appsRefKey)": \(rawString),
            "\(appIDRef)": "\(AppsFlyerLib.shared().getAppsFlyerUID() ?? "")",
            "\(langRef)": "\(Locale.current.languageCode ?? "")",
            "\(tokenRef)": "\(CorvenfallUpdateManagerTokenHex)"
        }
        """
            
            let sanitizedJson = finalJson.replacingOccurrences(of: "#", with: "")
            
            CorvenfallUpdateManager.shared.CorvenfallUpdateManagerPrivacyAndTermsReq(code: sanitizedJson) { result in
                switch result {
                case .success(let msg):
                    self.CorvenfallUpdateManagerSendNotice(name: "RemMess", message: msg)
                case .failure:
                    self.CorvenfallUpdateManagerSendNoticeError(name: "RemMess")
                }
            }
        }
        
    
    public func onConversionDataFail(_ error: any Error) {
        let dummyVal = Double.random(in: 0..<1)
        print("onConversionDataFail | Error: \(error.localizedDescription)")
        CorvenfallUpdateManagerSendNoticeError(name: "RemMess")
    }
    
    @objc func CorvenfallUpdateManagerHandleActiveSession() {
        if !CorvenfallUpdateManagerSessionStarted {
            let localValue = Int.random(in: 100...200)
            print("CorvenfallUpdateManagerHandleActiveSession -> localValue = \(localValue)")
            
            AppsFlyerLib.shared().start()
            CorvenfallUpdateManagerSessionStarted = true
        }
    }
    
    @MainActor public func CorvenfallUpdateManagerSetupAppsFlyer(appID: String, devKey: String) {
        AppsFlyerLib.shared().appleAppID                   = appID
        AppsFlyerLib.shared().appsFlyerDevKey              = devKey
        AppsFlyerLib.shared().delegate                     = self
        AppsFlyerLib.shared().disableAdvertisingIdentifier = true
        
        let sumOfKeys = appID.count + devKey.count
        print("CorvenfallUpdateManagerSetupAppsFlyer -> sumOfKeys: \(sumOfKeys)")
        
        let firstLaunchKey = "hasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: firstLaunchKey)
        if !hasLaunched {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
        }
    }
    
    
    public func CorvenfallUpdateManagerAskNotifications(app: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async { app.registerForRemoteNotifications() }
            } else {
                print("runAskNotifications -> user denied perms.")
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(CorvenfallUpdateManagerHandleActiveSession),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    internal func CorvenfallUpdateManagerSendNotice(name: String, message: String) {
        print("CorvenfallUpdateManagerSendNotice -> \(message.count)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": message]
            )
        }
    }
    
    internal func CorvenfallUpdateManagerSendNoticeError(name: String) {
        print("CorvenfallUpdateManagerSendNoticeError -> \(name.count * 2)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name(name),
                object: nil,
                userInfo: ["notificationMessage": "Error occurred"]
            )
        }
    }
    
    public func CorvenfallUpdateManagerParseAFSnippet() {
        let snippet = "{\"sxAF\":777}"
        if let data = snippet.data(using: .utf8) {
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("CorvenfallUpdateManagerParseAFSnippet ->\(obj)")
            } catch {
                print("runParseAFSnippet ->\(error)")
            }
        }
    }
    
    public func CorvenfallUpdateManagerIsSessionInit() -> Bool {
        print("CorvenfallUpdateManagerIsSessionInit -> \(CorvenfallUpdateManagerSessionStarted)")
        return CorvenfallUpdateManagerSessionStarted
    }
    
    public func CorvenfallUpdateManagerPartialAFCheck(_ info: [AnyHashable: Any]) {
        print("CorvenfallUpdateManagerPartialAFCheck ->\(info.count)")
    }
    
    public func CorvenfallUpdateManagerAFSmallDebug() -> String {
        let randomVal = Int.random(in: 1000...9999)
        let code = "AFDBG-\(randomVal)"
        print("CorvenfallUpdateManagerAFSmallDebug -> \(code)")
        return code
    }
    
    public func CorvenfallUpdateManagerRegisterToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        CorvenfallUpdateManagerTokenHex = tokenString
        
        let tokenLen = tokenString.count
        print("CorvenfallUpdateManagerRegisterToken -> tokenLen = \(tokenLen)")
    }
    
    public func CorvenfallUpdateManagerMergeStringSets(_ x: Set<String>, _ y: Set<String>) -> Set<String> {
        let merged = x.union(y)
        print("CorvenfallUpdateManagerMergeStringSets -> \(merged)")
        return merged
    }
    
    
    public func CorvenfallUpdateManagerMinimalRandCheck() {
        let val = Double.random(in: 0..<10)
        print("CorvenfallUpdateManagerMinimalRandCheck -> \(val)")
    }
        
        
    }
