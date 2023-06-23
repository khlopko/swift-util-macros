import SweetDeclarationsLib

@PublicInit
@GranularUpdate
public struct User {
    public let id: String
    public let name: Name
}

@PublicInit
@GranularUpdate
public struct Name {
    public let firstName: String
    public let lastName: String
}

let user = User(id: "1", name: .init(firstName: "Initial", lastName: "Name"))
print("Before update: \(user)")

let updated = User(from: user, name: .init(from: user.name, firstName: "Modified"))
print("After update: \(updated)")
