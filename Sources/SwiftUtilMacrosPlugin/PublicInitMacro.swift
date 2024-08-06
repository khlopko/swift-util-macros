//
//  PublicInitMacro.swift
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PublicInitMacro: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let properties = DeclarationProperty.gather(from: declaration, in: context)
        let result: SwiftSyntax.DeclSyntax = """
            public init(
            \(raw: properties.asInitParams(nillable: false))
            ) {
            \(raw: properties.asInitBody())
            }
            """
        return [result]
    }
}

extension PublicInitMacro {
    struct Message: DiagnosticMessage {
        var diagnosticID: MessageID { .init(domain: "pim", id: "def") }
        var severity: DiagnosticSeverity { .warning }
        var message: String
    }
}
