//
//  main.swift
//

import Foundation

import SweetDeclarationsLib

public typealias GetConnections = () -> [User]

@PublicInit(escaping: [GetConnections.self])
@GranularUpdate
public struct User {
    public let id: String
    public let name: Name
    public let getConnections: GetConnections
    public let getPublications: (_ startDate: Date) -> [String]
}

@PublicInit
@GranularUpdate
public struct Name {
    public let firstName: String
    public let lastName: String
}

let user = User(
    id: "1",
    name: Name(firstName: "Initial", lastName: "Name"),
    getConnections: { [] },
    getPublications: { _ in [] }
)
print("Before update: \(user)")

let updated = User(from: user, name: Name(from: user.name, firstName: "Modified"))
print("After update: \(updated)")
