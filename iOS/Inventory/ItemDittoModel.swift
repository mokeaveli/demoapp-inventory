//
//  InventoryItem.swift
//  Inventory
//
//  Created by Shunsuke Kondo on 2023/01/19.
//  Copyright © 2023 Ditto. All rights reserved.
//

import Foundation
import DittoSwift

/*
    This is a model to store in Ditto database.
    We don't store as `ItemViewModel` because some of the data don't need to be transmitted.
    For this case, Ditto only syncs its ID and counter.
    Separating models for Ditto and views could make sync performance better.
 */

struct ItemDittoModel {

    // MARK: - Collection Name

    static let collectionName = "inventories"

    // MARK: - Properties

    let _id: Int
    let counter: DittoCounter

    // MARK: - Initialization

    init(_ doc: DittoDocument) {
        self._id = doc["_id"].intValue
        self.counter = doc["counter"].counter ?? DittoCounter()
    }

}
