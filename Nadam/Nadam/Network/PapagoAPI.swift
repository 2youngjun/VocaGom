//
//  PapagoAPI.swift
//  Nadam
//
//  Created by 이영준 on 2023/02/04.
//

import Foundation

struct PapagoAPI {
    func requestMeaning(word: String) -> URLRequest {
        let param = "source=en&target=ko&text=\(word)"
        let paramData = param.data(using: .utf8)
        let naver_URL = URL(string: "https://openapi.naver.com/v1/papago/n2mt")
        
        let clientID = Bundle.main.cliendID
        let clientSecret = Bundle.main.cliendSecret
        
        var request = URLRequest(url: naver_URL!)
        request.httpMethod = "POST"
        request.addValue(clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        request.httpBody = paramData
        request.setValue(String(paramData!.count), forHTTPHeaderField: "Content-Length")
        
        return request
    }
}
