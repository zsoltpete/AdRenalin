//
//  DataProvider.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 16..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import Firebase


class  DataProvider {
    
    static let shared = DataProvider()
    
    var ref: DatabaseReference!
    let groupsRef = Database.database().reference(withPath: "rooms")
    
    private init() {
        ref = Database.database().reference()
    }
    
    func getRooms() -> Observable<[Room]> {
        return Observable.create({ (observer: AnyObserver<[Room]>) -> Disposable in
            self.groupsRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                var rooms: Array<Room> = []
                let enumerator = snapshot.children
                while let room = enumerator.nextObject() as? DataSnapshot {
                    rooms.append(Room(snapshot: room.value as! [String: AnyObject], for: room.key))
                }
                observer.on(.next(rooms))
                observer.on(.completed)
            })
            return Disposables.create()
        })
        
    }
}

