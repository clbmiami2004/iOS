//
//  APIController.swift
//  DadJokes
//
//  Created by Enayatullah Naseri on 12/21/19.
//  Copyright © 2019 John Kouris. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class APIController {
    private let baseURL = URL(string: "https://dadjokes-3fe30.firebaseio.com/.json")!
    
    struct HTTPMethod {
        static let get = "GET"
        static let put = "PUT"
        static let post = "POST"
        static let delete = "DELETE"
    }
    
    func signUp() {
        
    }
    
    
    func signIn() {
        
    }
    
    
    func post(joke: Joke, completion: @escaping () -> Void = {}) {
        let encoder = JSONEncoder()
        
        var request = URLRequest(url: baseURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.post
        
        do {
            request.httpBody = try encoder.encode(joke)
        } catch {
            print("Error encoding joke")
            completion()
            return
        }
        
        AF.request(request).response { (response) in
            switch response.result {
            case .success:
                print("Success")
            case .failure:
                print("Failed")
            }
        }
    }
    
    
    func fetchJokes() {
        
    }
    
    
    func updateJokes(){
        
    }
    
    
    func deleteJoke(){
        
    }
    
}
