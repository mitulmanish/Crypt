//
//  Array+SafeAccess.swift
//  Crypt
//
//  Created by Mitul Manish on 4/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//

import Foundation
extension Array {
    enum AccessError: Error {
        case outOfBounds
    }
    
    func getElementAt(index: Int) -> Result<Element, Error> {
        guard (startIndex..<endIndex).contains(index) else {
            return .failure(AccessError.outOfBounds)
        }
        return .success(self[index])
    }
}
