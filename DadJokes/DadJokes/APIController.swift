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
import CoreData

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}

struct HTTPMethod {
    static let get = "GET"
    static let put = "PUT"
    static let post = "POST"
    static let delete = "DELETE"
}

class APIController {
    private let baseURL = URL(string: "https://dadjokes-3fe30.firebaseio.com/")!
    
    init() {
        fetchJokesFromServer()
    }
    
    func signUp(username: String, email: String, password: String, completion: @escaping (Error?) -> Void = {_ in})  {
        let signUpURL = baseURL.appendingPathComponent("register")
        
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post // raw value
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue("USER_TOKEN", forHTTPHeaderField: "Authorization")
        
        let userParams = ["username": username, "email": email, "password": password] as [String: Any]
        do {
            let json = try JSONSerialization.data(withJSONObject: userParams, options: .prettyPrinted)
            request.httpBody = json
        } catch {
            NSLog("Error encoding JSON")
            return
        }
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                completion(NSError(domain:"", code: response.statusCode, userInfo: nil))
                return
            }
            if let error = error {
                completion(error)
                return
            }
            NSLog("Successfully signed up User")
            //                    self.signIn(email: email, password: password, completion: completion)
            
            completion(nil)
        } .resume()
    }
    
    func signIn() {
        
    }
    
    func put(joke: Joke, completion: @escaping () -> Void = {}) {
        let identifier = joke.identifier ?? UUID()
        joke.identifier = identifier
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.put
        
        guard let jokeRepresentation = joke.jokeRepresentation else {
            print("Joke representation is nil")
            completion()
            return
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(jokeRepresentation)
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
    
    @discardableResult func createJoke(question: String, answer: String) -> Joke {
        let joke = Joke(question: question, answer: answer, username: "", context: CoreDataStack.shared.mainContext)
        put(joke: joke)
        CoreDataStack.shared.save()
        return joke
    }
    
    func updateJoke(joke: Joke, with question: String, answer: String) {
        joke.question = question
        joke.answer = answer
        put(joke: joke)
        CoreDataStack.shared.save()
    }
    
    func delete(joke: Joke, completion: @escaping (Error?) -> Void = { _ in }) {
        let identifier = joke.identifier ?? UUID()
        joke.identifier = identifier
        
        let requestURL = baseURL.appendingPathComponent(identifier.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.delete
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(error)
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
        }.resume()
        
        CoreDataStack.shared.mainContext.delete(joke)
        CoreDataStack.shared.save()
    }
    
    func fetchJokesFromServer(completion: @escaping (Error?) -> Void = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HTTPMethod.get
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(error)
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(error)
                return
            }
            
            do {
                let jokeRepresentations = try JSONDecoder().decode([String: JokeRepresentation].self, from: data).map({ $0.value })
                self.updateJokes(with: jokeRepresentations)
            } catch {
                completion(error)
                return
            }
        }.resume()
    }
    
    func updateJokes(with representations: [JokeRepresentation]) {
        let identifiersToFetch = representations.compactMap({ UUID(uuidString: $0.identifier) })
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        
        var jokesToCreate = representationsByID
        
        let context = CoreDataStack.shared.mainContext
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<Joke> = Joke.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
                
                let existingJokes = try context.fetch(fetchRequest)
                
                for joke in existingJokes {
                    guard let identifier = joke.identifier,
                        let representation = representationsByID[identifier] else { continue }
                    
                    joke.answer = representation.answer
                    joke.question = representation.question
                    joke.username = representation.username
                    
                    jokesToCreate.removeValue(forKey: identifier)
                }
                
                for representation in jokesToCreate.values {
                    Joke(jokeRepresentation: representation, context: context)
                }
                
                CoreDataStack.shared.save(context: context)
            } catch {
                print("Error fetching jokes from persistent store: \(error)")
            }
        }
    }
    
}
