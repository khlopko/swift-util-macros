
@attached(member, names: arbitrary)
public macro PublicInit() = #externalMacro(module: "SweetDeclarationsPlugin", type: "PublicInitMacro")

@attached(member, names: arbitrary)
public macro GranularUpdate() = #externalMacro(module: "SweetDeclarationsPlugin", type: "GranularUpdateMacro")
