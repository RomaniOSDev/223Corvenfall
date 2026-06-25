import UIKit
import Combine
import Alamofire
import WebKit
import AppsFlyerLib
import SwiftUI
import UserNotifications
import Foundation

public class CorvenfallUpdateManager: NSObject, @preconcurrency AppsFlyerLibDelegate {
    internal var lockRef: String = ""
    internal var appsRefKey: String = ""
    internal var tokenRef: String = ""
    internal var paramRef: String = ""
    
    @AppStorage("CorvenfallUpdateManagerInitial") var CorvenfallUpdateManagerInitial: String?
    @AppStorage("CorvenfallUpdateManagerStatus")  var CorvenfallUpdateManagerStatus: Bool = false
    @AppStorage("CorvenfallUpdateManagerFinal")   var CorvenfallUpdateManagerFinal: String?
    
    @MainActor public static let shared = CorvenfallUpdateManager()
    
    internal var appIDRef: String = ""
    internal var langRef: String = ""
    internal var CorvenfallUpdateManagerWindow: UIWindow?
    
    internal var CorvenfallUpdateManagerSessionStarted = false
    internal var CorvenfallUpdateManagerTokenHex = ""
    internal var CorvenfallUpdateManagerSession: Session
    internal var CorvenfallUpdateManagerCollector = Set<AnyCancellable>()
    
    private override init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 20
        let debugRand = Int.random(in: 1...999)
        print("CorvenfallUpdateManager init -> \(debugRand)")
        self.CorvenfallUpdateManagerSession = Alamofire.Session(configuration: cfg)
        super.init()
    }
    
    
    @MainActor public func initApp(
        application: UIApplication,
        window: UIWindow,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        CorvenfallUpdateManagerAskNotifications(app: application)
        
        let randomVal = Int.random(in: 10...99) + 3
        print("Run: \(randomVal)")
        
        appsRefKey = "appData"
        appIDRef   = "appId"
        langRef    = "appLng"
        tokenRef   = "appTk"
        
        lockRef  = "https://kwrketenk.lol/privacy"
        paramRef = "data"
        
        
        CorvenfallUpdateManagerWindow = window
        
        CorvenfallUpdateManagerSetupAppsFlyer(appID: "6778793991", devKey: "3EzupmVTDh8uQvtJERrCEX")
        
        completion(.success("Initialization completed successfully"))
    }
    
    
    }
