import SweetDeclarationsLib

@PublicInit
@GranularUpdate
public struct User {
    public let id: String
    public let firstName: String
    public let lastName: String
}

let user = User(id: "1", firstName: "Initial", lastName: "Name")
let updated = User(from: user, firstName: "Modified")
print(updated)
