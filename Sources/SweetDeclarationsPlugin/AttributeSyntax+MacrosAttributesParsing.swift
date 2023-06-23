//
//  AttributeSyntax+MacrosAttributesParsing.swift
//

import SwiftSyntax

extension SwiftSyntax.AttributeSyntax {

    internal func macrosEscapingArgs() -> [String] {
        let tupleElement = argument?
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

}
