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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var push: SINManagedPush?
    var window: UIWindow?
    var callManager: CallManager?
    var providerDelegate: ProviderDelegate?
    var client: SINClient?
    var user = String()
//    var callKitProvider: SINCallKitProvider?
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        user = "qwer"
        
        initSinchClientWithUserID(userID: user)
        if let client = client, callManager == nil {
            callManager = CallManager(client: client)
            providerDelegate = ProviderDelegate(callManager: self.callManager ?? CallManager(client: client))
        } else {
            print("We have a problem in app delegate!")
        }
        
        push = Sinch.managedPush(with: SINAPSEnvironment.development)
        push?.delegate = self
        push?.setDesiredPushType(SINPushTypeVoIP)
        
        // if logged in
        push?.registerUserNotificationSettings()
        initSinchClientWithUserID(userID: user)
        
        
        return true
    }
    
    
    func initSinchClientWithUserID (userID: String) {
        if client == nil {
            client = Sinch.client(withApplicationKey: APPLICATION_KEY, applicationSecret: APPLICATION_SECRET, environmentHost: "sandbox.sinch.com", userId: userID)
            client?.setSupportCalling(true)
            client?.setSupportMessaging(false)
            client?.enableManagedPushNotifications()
            client?.delegate = self
            client?.call().delegate = self
            client?.start()
            client?.startListeningOnActiveConnection()
        }
    }
    
}

extension AppDelegate: SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate  {
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        return SINLocalNotification()
    }
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("Received a call from: \(call.remoteUserId)")
    }
    
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started successfully (version: \(Sinch.version)")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Error starting Sinch: \(error.localizedDescription)")
    }
    
    func client(_ client: SINClient!, logMessage message: String!, area: String!, severity: SINLogSeverity, timestamp: Date!) {
        if let message = message {
//            print("**SINCH-LOG**: \(message)")
        }
    }
    
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        providerDelegate?.reportIncomingCall(call)
    }
    
    func handleRemoteNotification(userInfo: [AnyHashable : Any]) {
        client?.relayRemotePushNotification(userInfo)
    }
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        handleRemoteNotification(userInfo: payload)
    }
}

