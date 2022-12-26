//
//  KeychainHelper.swift
//  tv-series
//
//  Created by Felipe Leite on 25/12/22.
//

import Foundation

struct KeychainHelper {
    
    /// Saves data for the given service.
    func save(_ data: Data, service: String) {
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
        ] as CFDictionary

        let res = SecItemAdd(query, nil)
        
        if res == errSecDuplicateItem {
            let query = [
                kSecAttrService: service,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
            
            let attributes = [ kSecValueData: data ] as CFDictionary

            SecItemUpdate(query, attributes)
        }
    }
    
    /// Reads data for the given service, if it exists.
    func read(service: String) -> Data? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecReturnData: true,
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return result as? Data
    }

}
