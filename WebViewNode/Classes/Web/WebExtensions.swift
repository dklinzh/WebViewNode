//
//  WebExtensions.swift
//  WebViewNode
//
//  Created by Daniel Lin on 2018/6/20.
//  Copyright (c) 2018 Daniel Lin. All rights reserved.

import WebKit

@available(iOS 11.0, *)
/// Get website cookies from WKWebsiteDataStore
///
/// - Parameters:
///   - domain: Specified domain of cookie
///   - results: The block of cookie properties dictionary
public func WebsiteCookies(for domain: String? = nil, results: @escaping ([String : Any]) -> Void)  {
    var cookieDict = [String : Any]()
    WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
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
public func WebJavaScriptCookies(_ cookies: [HTTPCookie]? = HTTPCookieStorage.shared.cookies) -> String? {
    guard let cookies = cookies else {
        return nil
    }
    
    var result = ""
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    for cookie in cookies {
        result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
        if let date = cookie.expiresDate {
            result += "expires=\(dateFormatter.string(from: date)); "
        }
        if (cookie.isSecure) {
            result += "secure; "
        }
        result += "'; "
    }
    return result
}

/// Removes all types of website data records from WKWebsiteDataStore.
public func WebsiteRemoveAllDataRecords() {
    if #available(iOS 9.0, *) {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records, completionHandler: {
                
            })
        }
    } else {
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let cookiesFolderPath = libraryPath + "/Cookies"
        try? FileManager.default.removeItem(atPath: cookiesFolderPath)
    }
}
