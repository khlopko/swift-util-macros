//
//  DeclarationProperty.swift
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

internal struct DeclarationProperty {

    internal static func gather(
        from declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) -> [DeclarationProperty] {
        declaration.memberBlock.members.compactMap { member -> DeclarationProperty? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
                return nil
            }
            let patternBindingSyntax = varDecl.bindings.first
            guard
                let propertyName = patternBindingSyntax?.pattern
                    .as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }
            let typeSyntax = patternBindingSyntax?.typeAnnotation?.type
            let propertyType: String
            let isClosure: Bool
            if let optionalType = typeSyntax?.as(OptionalTypeSyntax.self) {
                propertyType = optionalType.description
                isClosure = optionalType.wrappedType
                    .as(TupleTypeSyntax.self)?.elements.first?
                    .is(FunctionTypeSyntax.self) == true
            } else if let simpleType = typeSyntax?.as(SimpleTypeIdentifierSyntax.self)?.name.text {
                propertyType = simpleType
                isClosure = false
            } else if let closureType = typeSyntax?.as(FunctionTypeSyntax.self) {
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

    let propertyName: String
    let propertyType: String
    let isClosure: Bool

    func asInitParam(nillable: Bool, escapingPropertyTypes: [String]) -> String {
        let propertyType = decoratedType(
            for: self,
            nillable: nillable,
            isExplicitlyEscaping: { escapingPropertyTypes.contains($0) }
        )
        return "    \(propertyName): \(propertyType)"
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

}

extension [DeclarationProperty] {
    
    internal func asInitParams(
        escapingPropertyTypes: [String],
        nillable: Bool
    ) -> SwiftSyntax.DeclSyntax {
        SwiftSyntax.DeclSyntax(stringLiteral: map {
            $0.asInitParam(nillable: nillable, escapingPropertyTypes: escapingPropertyTypes)
        }
        .joined(separator: ",\n"))
    }

    internal func asInitBody(
        decorateAssignment: (_ propertyName: String) -> String = { $0 }
    ) -> SwiftSyntax.DeclSyntax {
        SwiftSyntax.DeclSyntax(stringLiteral: map {
            "self.\($0.propertyName) = \(decorateAssignment($0.propertyName))"
        }
        .joined(separator: "\n"))
    }

}
