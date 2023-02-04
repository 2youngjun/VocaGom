//
//  PapagoNetwork.swift
//  Nadam
//
//  Created by 이영준 on 2023/02/04.
//

import Foundation

class PapagoNetwork {
    private let session: URLSession
    let api = PapagoAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchMeaning(word: String, completion: @escaping (WordInformation?) -> Void) {
        let request = api.requestMeaning(word: word)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else { return }
            
            if let data = data {
                do {
                    let meaning = try JSONDecoder().decode(WordInformation.self, from: data)
                    completion(meaning)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}
