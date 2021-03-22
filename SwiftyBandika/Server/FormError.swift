//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormError {

    var formErrors = Array<String>()
    var formFields = Set<String>()
    var formIncomplete = false

    var isEmpty : Bool {
        get{
            formErrors.isEmpty && formFields.isEmpty
        }
    }

    func addFormError(_ s: String) {
        if !formErrors.contains(s) {
            formErrors.append(s)
        }
    }

    func addFormField(_ field: String) {
        formFields.insert(field)
    }

    func getFormErrorString() -> String {
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

    func hasFormErrorField(name: String) -> Bool {
        formFields.contains(name)
    }

}