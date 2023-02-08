//
//  WordInformation.swift
//  Nadam
//
//  Created by 이영준 on 2022/08/31.
//

import Foundation

struct WordInformation: Codable {
    let message: Message
}

struct Message: Codable {
    let result: Result
}

struct Result: Codable {
    let translatedWord: String
    
    enum CodingKeys: String, CodingKey {
        case translatedWord = "translatedText"
    }
}
