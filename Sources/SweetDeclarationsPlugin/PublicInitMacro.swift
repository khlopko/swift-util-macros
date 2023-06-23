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
        let members = declaration.memberBlock.members
        let params = members.compactMap { member -> (name: String, type: String)? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            guard
                let propertyName = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                let propertyType = varDecl.bindings.first?.typeAnnotation?.type.as(SimpleTypeIdentifierSyntax.self)?.name.text
            else {
                return nil
            }
            return (propertyName, propertyType)
        }
        let result: SwiftSyntax.DeclSyntax = """
        public init(
        \(raw: params.map { "    \($0.name): \($0.type)" }.joined(separator: ",\n"))
        ) {
        \(raw: params.map { "self.\($0.name) = \($0.name)" }.joined(separator: "\n"))
        }
        """
        return [result]
    }

}
