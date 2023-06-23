//
//  GranularUpdateMacro.swift
//

import Foundation

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GranularUpdateMacro: MemberMacro {

    enum GenerationError: Error {
        case unsupportedType
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let typeName = try typeName(from: declaration)
        let properties = gatherProperties(from: declaration)
        let result: SwiftSyntax.DeclSyntax = """
        public init(
            from another: \(raw: typeName),
        \(raw: initParams(from: properties, nillable: true))
        ) {
        \(raw: initBody(from: properties, decorateAssignment: { "\($0) ?? another.\($0)" }))
        }
        """
        return [result]
    }

    private static func typeName(
        from declaration: some SwiftSyntax.DeclGroupSyntax
    ) throws -> String {
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            return structDecl.identifier.text
        }
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            return classDecl.identifier.text
        }
        throw GenerationError.unsupportedType
    }

}
