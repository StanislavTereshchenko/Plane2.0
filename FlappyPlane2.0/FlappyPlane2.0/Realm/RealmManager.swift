//
//  RealmManager.swift
//  FlappyPlane2.0
//
//  Created by Stanislav Tereshchenko on 23.07.2023.
//

import Foundation
import RealmSwift
import UIKit

class RealmManager {
    static let shared = RealmManager()
    private init() {}
    let localRealm  = try! Realm()
    
    func saveModel<T: Object>(model: T) {
        do {
            try localRealm.write {
                if !(localRealm.objects(ModelForSavingProgress.self).contains(where: {$0.timeInTheAir == (model as! ModelForSavingProgress).timeInTheAir})) {
                    localRealm.add(model)
                }
            }
        } catch {
            postModel(error)
        }
    }
    
    func postModel(_ error: Error) {
        NotificationCenter.default.post(name: Notification.Name("RealmError"), object: error)
    }
    
    func observeRealmErrors(in vc: UIViewController, completion: @escaping(Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RealmError"), object: nil, queue: nil) { (notification) in
            completion(notification.object as? Error)
        }
    }
    
    func stopObservingError(in vc: UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name("RealmError"), object: nil)
    }

}
