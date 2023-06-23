//
//  DeclarationProperty.swift
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

internal struct DeclarationProperty {
    let propertyName: String
    let propertyType: String
    let isClosure: Bool
}

internal func gatherProperties(
    from declaration: some SwiftSyntax.DeclGroupSyntax,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
) -> [DeclarationProperty] {
    declaration.memberBlock.members.compactMap { member -> DeclarationProperty? in
        guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
            return nil
        }
        guard
            let propertyName = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else {
            return nil
        }
        let propertyType: String
        let isClosure: Bool
        if let simpleType = varDecl.bindings.first?.typeAnnotation?.type.as(SimpleTypeIdentifierSyntax.self)?.name.text {
            propertyType = simpleType
            isClosure = false
        } else if let closureType = varDecl.bindings.first?.typeAnnotation?.type.as(FunctionTypeSyntax.self) {
            propertyType = closureType.description
            isClosure = true
        } else {
            return nil
        }
        return DeclarationProperty(
            propertyName: propertyName,
            propertyType: propertyType,
            isClosure: isClosure
        )
    }
}

internal func initParams(
    from properties: [DeclarationProperty],
    escapingPropertyTypes: [String],
    nillable: Bool
) -> SwiftSyntax.DeclSyntax {
    SwiftSyntax.DeclSyntax(stringLiteral: properties
        .map {
            let propertyType = decoratedType(
                for: $0,
                nillable: nillable,
                isExplicitlyEscaping: { escapingPropertyTypes.contains($0) }
            )
            return "    \($0.propertyName): \(propertyType)"
        }
        .joined(separator: ",\n")
    )

}

private func decoratedType(
    for property: DeclarationProperty,
    nillable: Bool,
    isExplicitlyEscaping: (String) -> Bool
) -> String {
    var propertyType: String = property.propertyType
    let isExplicitlyEscaping = isExplicitlyEscaping(propertyType)
    if nillable {
        if property.isClosure {
            propertyType = "(\(propertyType))"
        }
        propertyType = "\(propertyType)? = nil"
    }
    let isNotNilClosure = property.isClosure && !nillable
    if isNotNilClosure || isExplicitlyEscaping {
        propertyType = "@escaping \(propertyType)"
    }
    return propertyType
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

internal func escapingArgs(from node: SwiftSyntax.AttributeSyntax) -> [String] {
    let tupleElement = node.argument?
        .as(TupleExprElementListSyntax.self)?.first?
        .as(TupleExprElementSyntax.self)
    guard tupleElement?.label?.text == "escaping" else {
        return []
    }
    return tupleElement?.expression.as(ArrayExprSyntax.self)?.elements.compactMap {
        $0
            .as(ArrayElementSyntax.self)?.expression
            .as(MemberAccessExprSyntax.self)?.base?
            .as(IdentifierExprSyntax.self)?.identifier.text
    } ?? []
}
