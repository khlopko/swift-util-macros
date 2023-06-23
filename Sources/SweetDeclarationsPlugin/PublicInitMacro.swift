//
//  PublicInitMacro.swift
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PublicInitMacro: MemberMacro {

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let escapingArgs = node.macrosEscapingArgs()
        let properties = DeclarationProperty.gather(from: declaration, in: context)
        let result: SwiftSyntax.DeclSyntax = """
        public init(
        \(raw: properties.asInitParams(escapingPropertyTypes: escapingArgs, nillable: false))
        ) {
        \(raw: properties.asInitBody())
        }
        """
        return [result]
    }

}
