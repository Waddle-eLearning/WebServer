//
//  CustomStringConvertible.swift
//  Server
//
//  Created by Hagen Hasenbalg on 01.06.17.
//
//

import Foundation

extension CustomStringConvertible {
    var description : String {
        var description: String = ""

        description = "- \(type(of: self)) - <\(Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque())>- \n"

        description += "{\n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                if let c = child as? CustomStringConvertible {
                    description += "\t\(propertyName): \(c.description)\n"
                }else {
                    description += "\t\(propertyName): \(child.value)\n"
                }

            }
        }
        description += "}"
        return description
    }
}
