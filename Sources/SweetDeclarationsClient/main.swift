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

@TestStub
final class SomeProtocolStub {
    func method1() throws {
        method1Calls += 1
    }

    func method2(value: Int) async {
        method2Args.append(value)
        if let method2Delay {
            try? await Task.sleep(nanoseconds: UInt64(method2Delay))
        }
    }

    func method3(values: [String]) async throws -> Int {
        return method3Result!
    }
}
