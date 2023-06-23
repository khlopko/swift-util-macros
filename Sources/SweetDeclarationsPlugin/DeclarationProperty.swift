//
//  DeclarationProperty.swift
//

import SwiftSyntax
import SwiftSyntaxBuilder

internal typealias DeclarationProperty = (propertyName: String, propertyType: String)

internal func gatherProperties(
    from declaration: some SwiftSyntax.DeclGroupSyntax
) -> [DeclarationProperty] {
    declaration.memberBlock.members.compactMap { member -> DeclarationProperty? in
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
}

internal func initParams(
    from properties: [DeclarationProperty],
    nillable: Bool
) -> SwiftSyntax.DeclSyntax {
    SwiftSyntax.DeclSyntax(stringLiteral: properties
        .map {
            var propertyType: String = $0.propertyType
            if nillable {
                propertyType = "\(propertyType)? = nil"
            }
            return "    \($0.propertyName): \(propertyType)"
        }
        .joined(separator: ",\n")
    )

}

internal func initBody(
    from properties: [DeclarationProperty],
    decorateAssignment: (_ propertyName: String) -> String = { $0 }
) -> SwiftSyntax.DeclSyntax {
    SwiftSyntax.DeclSyntax(stringLiteral: properties
        .map { "self.\($0.propertyName) = \(decorateAssignment($0.propertyName))" }
        .joined(separator: "\n")
    )
}
