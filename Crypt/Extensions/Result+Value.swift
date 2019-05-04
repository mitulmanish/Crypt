//
//  Result+Value.swift
//  Crypt
//
//  Created by Mitul Manish on 4/5/19.
//  Copyright © 2019 Mitul Manish. All rights reserved.
//
import Foundation

extension Result {
    var value: Success? {
        return try? get()
    }
}
