//
//  DataStore.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 20..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation

class DataStore {
    
    static let shared = DataStore()
    
    var rooms: [Room] = []
    var selectedRoom: Room?
    
}
