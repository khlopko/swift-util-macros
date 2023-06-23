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
        let escapingArgs = escapingArgs(from: node)
        let properties = gatherProperties(from: declaration, in: context)
        let result: SwiftSyntax.DeclSyntax = """
        public init(
        \(raw: initParams(from: properties, escapingPropertyTypes: escapingArgs, nillable: false))
        ) {
        \(raw: initBody(from: properties))
        }
        """
        return [result]
    }

}
