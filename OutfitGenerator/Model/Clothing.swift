//
//  Clothing.swift
//  OutfitGenerator
//
//  Created by Ashley Smith on 2/19/22.
//

import UIKit
import Foundation

public struct Clothing {
    public var shirtArray = UserDefaults.standard.stringArray(forKey: K.shirtArray)
    public var pantsArray = UserDefaults.standard.stringArray(forKey: K.pantsArray)
    public var shoesArray = UserDefaults.standard.stringArray(forKey: K.shoesArray)

    public func saveClothes() {
        UserDefaults.standard.set(shirtArray, forKey: K.shirtArray)
        UserDefaults.standard.set(pantsArray, forKey: K.pantsArray)
        UserDefaults.standard.set(shoesArray, forKey: K.shoesArray)
    }
}
