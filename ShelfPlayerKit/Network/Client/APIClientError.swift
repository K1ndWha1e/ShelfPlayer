//
//  APIClientError.swift
//  ShelfPlayer
//
//  Created by Rasmus Krämer on 28.07.25.
//

import Foundation

public enum APIClientError: Error {
    case parseError
    case serializeError
    
    case invalidItemType
    case invalidResponseCode
    
    case notFound
}
