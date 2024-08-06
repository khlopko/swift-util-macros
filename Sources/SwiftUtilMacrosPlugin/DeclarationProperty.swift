//
//  DeclarationProperty.swift
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

internal struct DeclarationProperty {
    let propertyName: String
    let propertyType: String
    let isClosure: Bool
    let explicitlyEscaping: Bool
}

extension DeclarationProperty {
    func asInitParam(nillable: Bool) -> String {
        let propertyType = decoratedType(
            for: self,
            nillable: nillable,
            isExplicitlyEscaping: { _ in explicitlyEscaping }
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
        if !nillable && isExplicitlyEscaping {
            propertyType = "@escaping \(propertyType)"
        }
        return propertyType
    }
}

extension DeclarationProperty {
    static func gather(
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
            let isComputed = varDecl.bindings.contains { $0.accessorBlock != nil }
            guard !isComputed else {
                return nil
            }
            let typeSyntax = patternBindingSyntax?.typeAnnotation?.type
            let propertyType: String
            let isClosure: Bool
            let explicitlyEscaping: Bool
            if let optionalType = typeSyntax?.as(OptionalTypeSyntax.self) {
                propertyType = optionalType.description
                isClosure =
                    optionalType.wrappedType
                    .as(TupleTypeSyntax.self)?.elements.first?.type
                    .is(FunctionTypeSyntax.self) == true
                explicitlyEscaping = false
            } else if let simpleType = typeSyntax?.as(IdentifierTypeSyntax.self)?.name.text {
                propertyType = simpleType
                isClosure = false
                explicitlyEscaping = false
            } else if let closureType = typeSyntax?.as(FunctionTypeSyntax.self) {
                propertyType = closureType.description
                isClosure = true
                explicitlyEscaping = true
            } else {
                context.diagnose(
                    Diagnostic(node: varDecl._syntaxNode, message: TypeNotFoundMessage()))
                return nil
            }
            return DeclarationProperty(
                propertyName: propertyName,
                propertyType: propertyType,
                isClosure: isClosure,
                explicitlyEscaping: explicitlyEscaping
            )
        }
    }
}

extension [DeclarationProperty] {
    internal func asInitParams(
        nillable: Bool
    ) -> SwiftSyntax.DeclSyntax {
        SwiftSyntax.DeclSyntax(
            stringLiteral: map {
                $0.asInitParam(nillable: nillable)
            }
            .joined(separator: ",\n")
        )
    }

    internal func asInitBody(
        decorateAssignment: (_ propertyName: String) -> String = { $0 }
    ) -> SwiftSyntax.DeclSyntax {
        SwiftSyntax.DeclSyntax(
            stringLiteral: map {
                "self.\($0.propertyName) = \(decorateAssignment($0.propertyName))"
            }
            .joined(separator: "\n")
        )
    }
}

extension DeclarationProperty {
    struct TypeNotFoundMessage: DiagnosticMessage {
        let message =
            "Property type not found or not supported. Specify type explicitly if its missing to fix this error"
        let diagnosticID = SwiftDiagnostics.MessageID(domain: "PublicInitMacro", id: "TypeNotFound")
        let severity: SwiftDiagnostics.DiagnosticSeverity = .error
    }
}
