//
//  Users.swift
//  Hotline
//
//  Created by Besher on 2018-06-10.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation


struct Users {
    private var users = [String]()
    static var list = Users()
    
    init() {
        users.append("Besher's iPhone")
        users.append("Besher's iPad")
    }
    
    func getUserList() -> [String] {
        return users
    }
}
