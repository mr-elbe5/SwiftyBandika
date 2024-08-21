/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class UserData: BaseData {

    public static var ID_ROOT: Int = 1
    public static var minPasswordLength : Int = 8

    private enum UserDataCodingKeys: CodingKey {
        case title
        case firstName
        case lastName
        case email
        case login
        case passwordHash
        case street
        case zipCode
        case city
        case country
        case phone
        case groupIds
    }

    public var title: String
    public var firstName: String
    public var lastName: String
    public var email: String
    public var login: String
    public var passwordHash: String
    public var street: String
    public var zipCode: String
    public var city: String
    public var country: String
    public var phone: String
    public var groupIds: Array<Int>

    public var isRoot: Bool {
        get {
            id == UserData.ID_ROOT
        }
    }

    override public var type: DataType {
        get {
            .user
        }
    }

    public var name : String{
        get{
            firstName + " " + lastName
        }
    }

    override public init() {
        title = ""
        firstName = ""
        lastName = ""
        email = ""
        login = ""
        passwordHash = UserSecurity.encryptPassword(password: "pass")
        street = ""
        zipCode = ""
        city = ""
        country = ""
        phone = ""
        groupIds = Array<Int>()
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: UserDataCodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        email = try values.decodeIfPresent(String.self, forKey: .email) ?? ""
        login = try values.decodeIfPresent(String.self, forKey: .login) ?? ""
        passwordHash = try values.decodeIfPresent(String.self, forKey: .passwordHash) ?? UserSecurity.encryptPassword(password: "pass")
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        zipCode = try values.decodeIfPresent(String.self, forKey: .zipCode) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
        country = try values.decodeIfPresent(String.self, forKey: .country) ?? ""
        phone = try values.decodeIfPresent(String.self, forKey: .phone) ?? ""
        groupIds = try values.decodeIfPresent(Array<Int>.self, forKey: .groupIds) ?? Array<Int>()
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: UserDataCodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(login, forKey: .login)
        try container.encode(passwordHash, forKey: .passwordHash)
        try container.encode(street, forKey: .street)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(phone, forKey: .phone)
        try container.encode(groupIds, forKey: .groupIds)
    }

    override public func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let userData = data as? UserData {
            title = userData.title
            firstName = userData.firstName
            lastName = userData.lastName
            email = userData.email
            login = userData.login
            passwordHash = userData.passwordHash
            street = userData.street
            zipCode = userData.zipCode
            city = userData.city
            country = userData.country
            phone = userData.phone
            groupIds.removeAll()
            groupIds.append(contentsOf: userData.groupIds)
        }
    }

    public func hasPassword() -> Bool {
        !passwordHash.isEmpty
    }

    public func setPassword(password: String) {
        if password.isEmpty {
            passwordHash = ""
        } else {
            passwordHash = UserSecurity.encryptPassword(password: password)
        }
    }

    public func addGroupId(_ id: Int) {
        groupIds.append(id)
    }

    public func removeGroupId(_ id: Int) {
        groupIds.remove(obj: id)
    }

    override public func readRequest(_ request: Request) {
        super.readRequest(request);
        readBasicData(request);
        login = request.getString("login")
        let s1 = request.getString("password")
        let s2 = request.getString("passwordCopy")
        if !s1.isEmpty || !s2.isEmpty {
            if s1 == s2 {
                setPassword(password: s1)
            } else {
                request.addFormError("_passwordsDontMatch".localize(language: request.language))
                request.addFormField("password")
                request.addFormField("passwordCopy")
            }
        }
        groupIds = request.getIntArray("groupIds") ?? Array<Int>()
        if login.isEmpty {
            request.addIncompleteField("login")
        }
        if isNew && !hasPassword() {
            request.addIncompleteField("password")
        }
    }


    public func readProfileRequest(_ request: Request) {
        readBasicData(request);
    }

    public func readBasicData(_ request: Request) {
        title = request.getString("title")
        firstName = request.getString("firstName")
        lastName = request.getString("lastName")
        email = request.getString("email")
        street = request.getString("street")
        zipCode = request.getString("zipCode")
        city = request.getString("city")
        country = request.getString("country")
        phone = request.getString("phone")
        if lastName.isEmpty {
            request.addIncompleteField("lastName")
        }
        if email.isEmpty {
            request.addIncompleteField("email")
        }
    }

}

