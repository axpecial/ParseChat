//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Andy Duong on 2/26/18.
//  Copyright © 2018 Andy Duong. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController, UITableViewDataSource {

    // MARK: Properties
    @IBOutlet weak var chatMessageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatMessageLogTableView: UITableView!
    
    var chatMessages: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        chatMessageLogTableView.dataSource = self
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ChatViewController.onTimer), userInfo: nil, repeats: true)
        
        // Auto size row height based on cell autolayout constraints
        chatMessageLogTableView.rowHeight = UITableViewAutomaticDimension
        // Provide an estimated row height. Used for calculating scroll indicator
        chatMessageLogTableView.estimatedRowHeight = 50
    }

    // MARK: Actions
    @IBAction func sendButtonPressed(_ sender: Any) {
        let chatMessage = PFObject(className: "Message")
        chatMessage["user"] = PFUser.current()
        chatMessage["text"] = chatMessageField.text ?? ""
        chatMessage.saveInBackground { (success, error) in
            if success {
                print("The message was saved!")
                self.chatMessageField.text = ""
            } else if let error = error {
                print("Problem saving message: \(error.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatMessageLogTableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        let message = chatMessages![indexPath.row]
        cell.chatMessageLabel.text = message["text"] as? String
        
        // Setting username 
        if let user = message["user"] as? PFUser {
            // User found! update username label with username
            cell.usernameLabel.text = user.username
        } else {
            // No user found, set default username
            cell.usernameLabel.text = "🤖"
        }
        
        return cell
    }
    
    @objc func onTimer() {
        // Add code to be run periodically
        let query = PFQuery(className: "Message")
        query.addDescendingOrder("createdAt")
        query.includeKey("user")
        query.includeKey("text")
        
        // fetch data asynchronously
        query.findObjectsInBackground { (chatMessages: [PFObject]?, error: Error?) in
            if error == nil {
                
                // Save the array of messages (PFObjects)
                self.chatMessages = chatMessages
                
                // Reload the table view
                self.chatMessageLogTableView.reloadData()
                
            } else {
                print(error?.localizedDescription ?? "Error")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
