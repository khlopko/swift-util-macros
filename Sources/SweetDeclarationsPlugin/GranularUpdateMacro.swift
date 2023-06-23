//
//  GranularUpdateMacro.swift
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GranularUpdateMacro: MemberMacro {

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let typeName = declaration.as(StructDeclSyntax.self)?.identifier.text ?? ""
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
            from another: \(raw: typeName),
        \(raw: params.map { "    \($0.name): \($0.type)? = nil" }.joined(separator: ",\n"))
        ) {
        \(raw: params.map { "self.\($0.name) = \($0.name) ?? another.\($0.name)" }.joined(separator: "\n"))
        }
        """
        return [result]
    }

}
