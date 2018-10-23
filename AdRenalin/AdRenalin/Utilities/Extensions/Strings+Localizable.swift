//
//  Strings+Localizable.swift
//  AdRenalin
//
//  Created by Zsolt Pete on 2018. 10. 23..
//  Copyright © 2018. Zsolt Pete. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localizeWithFormat(args: CVarArg...) -> String {
        return String(format: self.localized, locale: nil, arguments: args)
    }
    
    func localizeWithFormat(local:NSLocale?, args: CVarArg...) -> String {
        return String(format: self.localized, locale: local as Locale?, arguments: args)
    }
}

