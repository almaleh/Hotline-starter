/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

private let presentIncomingCallViewControllerSegue = "PresentIncomingCallViewController"
private let presentOutgoingCallViewControllerSegue = "PresentOutgoingCallViewController"
private let callCellIdentifier = "CallCell"

class CallsViewController: UITableViewController {
    
    fileprivate var users: [String] {
        let userStruct = Users.list
        return userStruct.getUserList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CallManager.sharedInstance.reloadTable = {
            [unowned self] in
            print("REFRESHING TABLE")
            self.tableView.reloadData()
        }
        
        CallManager.sharedInstance.updateDelegates = {
            [unowned self] in
            print("Updating audio delegate")
//            CallManager.sharedInstance.client.audioController().delegate = self.acDelegate
            
            // QUESTIONABLE LINE, MAY RE-ADD LATER
//            self.callManager.currentCall?.delegate = self
        }
        
    }
    
    @IBAction private func unwindForNewCall(_ segue: UIStoryboardSegue) {       
        guard let newCallController = segue.source as? NewCallViewController else { return }
        guard let handle = newCallController.handle, handle != "" else { return }
        ProviderDelegate.sharedInstance.startCall(handle: handle)
        
    }
}

// MARK: - UITableViewDataSource

extension CallsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users.count
        } else {
            return CallManager.sharedInstance.calls.count
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Usernames"
        } else {
            return "Calls"
        }
    }
    
//    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        if index == 0 {
//            title = "Calls"
//        } else {
//            title = "Calls"
//        }
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: callCellIdentifier) as! CallTableViewCell
        if indexPath.section == 0 {
            let remoteUserID = users[indexPath.row]
            cell.callerHandle = remoteUserID
            if let call = CallManager.sharedInstance.callWithHandle(remoteUserID) {
                cell.callState = call.state
                cell.incoming = (call.direction == .incoming)
                cell.hideIcon(false)
            } else {
                cell.defaultLabel()
                cell.hideIcon(true)
            }
        } else {
            let call = CallManager.sharedInstance.calls[indexPath.row]
            cell.callerHandle = call.uuid.uuidString
            cell.incoming = call.direction == .incoming
            cell.callState = call.state
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let handle = users[indexPath.row]
        if let call = CallManager.sharedInstance.callWithHandle(handle) {
            ProviderDelegate.sharedInstance.end(call: call)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let handle = users[indexPath.row]
        if CallManager.sharedInstance.callWithHandle(handle) != nil {
            return .delete
        }
        return .none
    }
    
}

// MARK - UITableViewDelegate

extension CallsViewController {
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "Remove"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let call = callManager.calls[indexPath.row]
//        let onHold = acDelegate.muted ? false : true
//        print("Are we currently muted? \(acDelegate.muted)")
//        callManager?.setMute(call: call, mute: onHold)
        if indexPath.section == 0 {
            let handle = users[indexPath.row]
            if CallManager.sharedInstance.callWithHandle(handle) == nil {
                ProviderDelegate.sharedInstance.startCall(handle: handle)
                //            tableView.reloadData()
            } else {
                if let currentCall = CallManager.sharedInstance.currentCall {
                    ProviderDelegate.sharedInstance.setMute(call: currentCall, mute: true)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
