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
    
    fileprivate var callManager: CallManager!
    fileprivate var acDelegate: AudioControllerDelegate!
    fileprivate var users: [String] {
        let userStruct = Users.list
        return userStruct.getUserList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callManager = AppDelegate.shared.callManager
        acDelegate = AudioControllerDelegate()
        
        callManager.reloadTable = {
            [unowned self] in
            print("REFRESHING TABLE")
            self.tableView.reloadData()
        }
        
        callManager.updateData = {
            [unowned self] in
            print("Updating delegate")
            self.callManager.currentCall?.delegate = self
            self.callManager.client.audioController().delegate = self.acDelegate
        }
    }
    
    @IBAction private func unwindForNewCall(_ segue: UIStoryboardSegue) {       
        guard let newCallController = segue.source as? NewCallViewController else { return }
        guard let handle = newCallController.handle, handle != "" else { return }
        callManager.startCall(handle: handle)
        
    }
}

// MARK: - UITableViewDataSource

extension CallsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callManager.calls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let call = callManager.calls[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: callCellIdentifier) as! CallTableViewCell
        cell.callerHandle = call.remoteUserId
        cell.callState = call.state
        cell.incoming = (call.direction == .incoming)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let call = callManager.calls[indexPath.row]
        callManager.end(call: call)
    }
}

// MARK - UITableViewDelegate

extension CallsViewController {
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "Remove"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let call = callManager.calls[indexPath.row]
        let onHold = acDelegate.muted ? false : true
        print("Are we currently muted? \(acDelegate.muted)")
//        callManager?.setHeld(call: call, onHold: onHold)
        callManager?.setMute(call: call, mute: onHold)
        
        tableView.reloadData()
    }
}

extension CallsViewController: SINCallDelegate {
    
    func callDidProgress(_ call: SINCall!) {
        self.tableView.reloadData()
        print("RINGING")
    }
    
    func callDidEstablish(_ call: SINCall!) {
        
        self.tableView.reloadData()
        print("STARTING CALL")
    }
    
    func callDidEnd(_ call: SINCall!) {
        callManager.end(call: call)
        self.tableView.reloadData()
        print("CALL ENDED")
    }
    
    func call(_ call: SINCall!, shouldSendPushNotifications pushPairs: [Any]!) {
//        TODO
    }
    
    
}
