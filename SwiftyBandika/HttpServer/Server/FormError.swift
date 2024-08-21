/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

public class FormError {

    public var formErrors = Array<String>()
    public var formFields = Set<String>()
    public var formIncomplete = false

    public var isEmpty : Bool {
        get{
            formErrors.isEmpty && formFields.isEmpty
        }
    }

    public func addFormError(_ s: String) {
        if !formErrors.contains(s) {
            formErrors.append(s)
        }
    }

    public func addFormField(_ field: String) {
        formFields.insert(field)
    }

    public func getFormErrorString() -> String {
        if formErrors.isEmpty || formErrors.isEmpty {
            return ""
        }
        if formErrors.count == 1 {
            return formErrors[0]
        }
        var s = ""
        for formError in formErrors {
            if s.count > 0 {
                s.append("\n")
            }
            s.append(formError)
        }
        return s
    }

    public func hasFormErrorField(name: String) -> Bool {
        formFields.contains(name)
    }

}