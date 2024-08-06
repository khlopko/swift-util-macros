//
//  Macros.swift
//

@attached(member, names: arbitrary)
public macro PublicInit() = #externalMacro(module: "SwiftUtilMacrosPlugin", type: "PublicInitMacro")

@attached(member, names: arbitrary)
public macro PublicInit(escaping: [Any.Type]) = #externalMacro(module: "SwiftUtilMacrosPlugin", type: "PublicInitMacro")

@attached(member, names: arbitrary)
public macro GranularUpdate() = #externalMacro(module: "SwiftUtilMacrosPlugin", type: "GranularUpdateMacro")

@attached(member, names: arbitrary)
public macro TestStub() = #externalMacro(module: "SwiftUtilMacrosPlugin", type: "TestStubMacro")

@attached(member)
@attached(extension, conformances: OptionSet)
public macro BitMask() = #externalMacro(module: "SwiftUtilMacrosPlugin", type: "BitMaskOptionSetMacro")

