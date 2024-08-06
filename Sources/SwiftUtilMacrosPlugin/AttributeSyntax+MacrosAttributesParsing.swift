//
//  AttributeSyntax+MacrosAttributesParsing.swift
//

import SwiftSyntax

extension SwiftSyntax.AttributeSyntax {
    internal func macrosEscapingArgs() -> [String] {
        let tupleElement = arguments?.as(LabeledExprListSyntax.self)?.first
        guard tupleElement?.label?.text == "escaping" else {
            return []
        }
        return tupleElement?.expression.as(ArrayExprSyntax.self)?.elements.compactMap { element in
            element.expression
                .as(MemberAccessExprSyntax.self)?.base?
                .as(DeclReferenceExprSyntax.self)?.baseName.text
        } ?? []
    }
}
