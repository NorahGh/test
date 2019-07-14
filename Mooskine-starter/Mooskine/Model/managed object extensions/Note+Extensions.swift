//
//  Note+Extensions.swift
//  Mooskine
//
//  Created by Saud Abdullah on 08/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Note
{
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
