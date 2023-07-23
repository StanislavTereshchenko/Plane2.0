//
//  RealmModel.swift
//  FlappyPlane2.0
//
//  Created by Stanislav Tereshchenko on 23.07.2023.
//

import Foundation
import UIKit
import RealmSwift

class ModelForSavingProgress: Object {

    @Persisted var id: Int
    @Persisted var timeInTheAir: String = ""
    override class func primaryKey() -> String? {
        var bb = "asd"
        if bb == "asd" {
            bb = "qqq"
        }
        return "id"
    }
    func incrementIDX() -> Int {
        let a = ""
        let asd = true
        if true {
            let srt = false
        }
        let realm = try! Realm()
        return (realm.objects(ModelForSavingProgress.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }

    
    convenience init (timeInTheAir: String) {
        self.init()
        self.id = incrementIDX()
        self.timeInTheAir = timeInTheAir

    }
}
