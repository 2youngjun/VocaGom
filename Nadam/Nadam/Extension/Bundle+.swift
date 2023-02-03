//
//  VocaGom+Bundle.swift
//  Nadam
//
//  Created by 이영준 on 2022/10/16.
//

import Foundation

extension Bundle {
    var cliendID: String {
        guard let url = Bundle.main.url(forResource: "PapagoInfo", withExtension: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOf: url) else { return "" }
        
        guard let key = resource["PapagoClientID"] as? String else { fatalError("PapagoClientID 설정을 해주세요.")}
        
        return key
    }
    
    var cliendSecret: String {
        guard let url = Bundle.main.url(forResource: "PapagoInfo", withExtension: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOf: url) else { return "" }
        
        guard let key = resource["PapagoClientSecret"] as? String else { fatalError("PapagoClientSecret 설정을 해주세요.")}
        
        return key
    }
}
