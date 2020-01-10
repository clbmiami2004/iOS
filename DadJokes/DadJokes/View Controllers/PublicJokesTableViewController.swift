//
//  PublicJokesTableViewController.swift
//  DadJokes
//
//  Created by John Kouris on 12/18/19.
//  Copyright © 2019 John Kouris. All rights reserved.
//

import UIKit

class PublicJokesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
//    var jokesTest = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        jokesTest = ["Joke1", "Joke2", "Joke3"]

    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1 // test
//    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return jokesTest.count
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicJokeCell", for: indexPath)
        
//        cell.textLabel?.text = jokesTest[indexPath.row]

        return cell
    }
    
    // Alert
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.presentDJAlertOnMainThread(title: "Sign Up Alert!", message: DJError.singupError.rawValue, buttonTitle: "Ok")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
