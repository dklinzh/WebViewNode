//
//  WebKitExtensions.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/6/20.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.
//

import WebKit

public struct WebKit {
    // MARK: Public

    /// A custom UserAgent begins with the app bundle name.
    public static var customUserAgent: String {
        #if os(iOS)
        return String(format: "%@/%@ (%@; iOS %@; Scale/%.2f)",
                      (Bundle.main.object(forInfoDictionaryKey: kCFBundleExecutableKey as String) as? String) ?? (Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String) ?? "",
                      (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? (Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String) ?? "",
                      UIDevice.current.model,
                      UIDevice.current.systemVersion,
                      UIScreen.main.scale)
        #elseif os(macOS)
        return String(format: "%@/%@ (macOS %@)",
                      (Bundle.main.object(forInfoDictionaryKey: kCFBundleExecutableKey as String) as? String) ?? (Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String) ?? "",
                      (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? (Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String) ?? "",
                      ProcessInfo.processInfo.operatingSystemVersionString)
        #endif
    }

    /// Apply the custom User-Agnet to user defaults for the url request of web view.
    ///
    /// - Parameters:
    ///   - customUserAgent: The custom User-Agent to be applied.
    ///   - appendDefault: Determine whether the custom User-Agent should append with the defaults User-Agent of web view.
    public static func applyCustomUserAgent(_ customUserAgent: String = WebKit.customUserAgent, appendDefault: Bool = true) {
        if appendDefault {
            _tempWebView = WKWebView()
            _tempWebView!.evaluateJavaScript("navigator.userAgent") { result, _ in
                if let userAgent = result as? String {
                    UserDefaults.standard.register(defaults: ["UserAgent": customUserAgent + " " + userAgent])
                }

                _tempWebView = nil
            }
        } else {
            UserDefaults.standard.register(defaults: ["UserAgent": customUserAgent])
        }
    }

    /// Get website cookies from WKWebsiteDataStore
    ///
    /// - Parameters:
    ///   - domain: Specified domain of cookie
    ///   - results: The block of cookie properties dictionary
    @available(iOS 11.0, *)
    public static func websiteCookies(for domain: String? = nil, results: @escaping ([String: Any]) -> Void) {
        var cookieDict = [String: Any]()
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            if let domain = domain {
                for cookie in cookies {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties
                    }
                }
            } else {
                for cookie in cookies {
                    cookieDict[cookie.name] = cookie.properties
                }
            }

            results(cookieDict)
        }
    }

    /// Get HTTP cookies in web JavaScript format
    ///
    /// - Parameter cookies: Array of HTTP cookies
    /// - Returns: Cookies string with JavaScript format
    public static func formatJavaScriptCookies(_ cookies: [HTTPCookie]? = HTTPCookieStorage.shared.cookies) -> String? {
        guard let cookies = cookies else {
            return nil
        }

        var result: String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if cookie.isSecure {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }

    /// Removes all types of website data records.
    public static func removeAllWebsiteDataRecords() {
        if #available(iOS 9.0, *) {
            let dataStore = WKWebsiteDataStore.default()
            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            dataStore.fetchDataRecords(ofTypes: dataTypes) { records in
                dataStore.removeData(ofTypes: dataTypes, for: records, completionHandler: {})
            }
        } else {
            _removeWebsiteDataFiles()
        }
    }

    /// Removes the specified types of website data records.
    public static func removeWebsiteDataRecords(types: [WebsiteDataType] = [.fetchCache, .serviceWorkerRegistrations,
                                                                            .diskCache, .memoryCache, .offlineWebApplicationCache, .sessionStorage,
                                                                            .cookies, .localStorage, .webSQLDatabases, .indexedDBDatabases])
    {
        if types.isEmpty {
            return
        }

        if #available(iOS 9.0, *) {
            let date = Date(timeIntervalSince1970: 0)
            let typeValues = types.map { (type) -> String in
                type.rawValue
            }
            WKWebsiteDataStore.default().removeData(ofTypes: Set<String>(typeValues), modifiedSince: date) {}
        } else {
            _removeWebsiteDataFiles(types: types)
        }
    }

    /// Register the specified schemes for the custom URL protocol. Not Recommended.
    ///
    /// - Parameter schemes: An array of custom schemes to be registered.
    public static func registerURLProtocol(schemes: [String]) {
        if schemes.isEmpty {
            return
        }

        if let cls = NSClassFromString("W" + "K" + "BrowsingContext" + "Controller") {
            let sel = NSSelectorFromString("register" + "Scheme" + "For" + "CustomProtocol" + ":")
            if cls.responds(to: sel) {
                let obj = cls as AnyObject
                schemes.forEach { scheme in
                    _ = obj.perform(sel, with: scheme)
                }
            }
        }
    }

    /// Unregister the specified schemes for the custom URL protocol. Not Recommended.
    ///
    /// - Parameter schemes: An array of custom schemes to be unregistered.
    public static func unregisterURLProtocol(schemes: [String]) {
        if schemes.isEmpty {
            return
        }

        if let cls = NSClassFromString("W" + "K" + "BrowsingContext" + "Controller") {
            let sel = NSSelectorFromString("unregister" + "Scheme" + "For" + "CustomProtocol" + ":")
            if cls.responds(to: sel) {
                let obj = cls as AnyObject
                schemes.forEach { scheme in
                    _ = obj.perform(sel, with: scheme)
                }
            }
        }
    }

    // MARK: Private

    private static var _tempWebView: WKWebView?

    private static func _removeWebsiteDataFiles(types: [WebsiteDataType] = [.cookies, .localStorage, .webSQLDatabases, .indexedDBDatabases]) {
        let fileManager = FileManager.default
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        if types.contains(.cookies) {
            try? fileManager.removeItem(atPath: libraryPath + "/Cookies")
        }

        if let bundleID = Bundle.main.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String {
            let storageFilePath = libraryPath + "WebKit/\(bundleID)/WebsiteData"
            if types.contains(.localStorage) {
                try? fileManager.removeItem(atPath: storageFilePath + "/LocalStorage")
            }
            if types.contains(.webSQLDatabases) {
                try? fileManager.removeItem(atPath: storageFilePath + "/WebSQL")
            }
            if types.contains(.indexedDBDatabases) {
                try? fileManager.removeItem(atPath: storageFilePath + "/IndexedDB")
            }
        }
    }
}

/// The types of website data
///
/// - fetchCache: On-disk Fetch caches. @available(iOS 11.3, *)
/// - serviceWorkerRegistrations: Service worker registrations. @available(iOS 11.3, *)
/// - diskCache: On-disk caches. @available(iOS 9.0, *)
/// - memoryCache: In-memory caches. @available(iOS 9.0, *)
/// - offlineWebApplicationCache: HTML offline web application caches. @available(iOS 9.0, *)
/// - sessionStorage: HTML session storage. @available(iOS 9.0, *)
/// - cookies: Cookies. @available(iOS 8.0, *)
/// - localStorage: HTML local storage. @available(iOS 8.0, *)
/// - webSQLDatabases: WebSQL databases. @available(iOS 8.0, *)
/// - indexedDBDatabases: IndexedDB databases. @available(iOS 8.0, *)
public enum WebsiteDataType: String {
    // @available(iOS 11.3, *)
    case fetchCache = "WKWebsiteDataTypeFetchCache"
    case serviceWorkerRegistrations = "WKWebsiteDataTypeServiceWorkerRegistrations"

    // @available(iOS 9.0, *)
    case diskCache = "WKWebsiteDataTypeDiskCache"
    case memoryCache = "WKWebsiteDataTypeMemoryCache"
    case offlineWebApplicationCache = "WKWebsiteDataTypeOfflineWebApplicationCache"
    case sessionStorage = "WKWebsiteDataTypeSessionStorage"

    // @available(iOS 8.0, *)
    case cookies = "WKWebsiteDataTypeCookies"
    case localStorage = "WKWebsiteDataTypeLocalStorage"
    case webSQLDatabases = "WKWebsiteDataTypeWebSQLDatabases"
    case indexedDBDatabases = "WKWebsiteDataTypeIndexedDBDatabases"
}
