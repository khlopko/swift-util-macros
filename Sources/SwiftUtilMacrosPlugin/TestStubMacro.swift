//
//  TestStubMacro.swift
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TestStubMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        declaration.memberBlock.members.flatMap { member -> [DeclSyntax] in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
                return []
            }
            let parameters = funcDecl.signature.input.parameterList
            let nameBase = funcDecl.identifier.text
            let callTrackSuffix: String
            if parameters.isEmpty {
                callTrackSuffix = "Calls: Int = 0"
            } else if parameters.count == 1 {
                let parametersList = parameters.map { $0.type.description }.joined(separator: ", ")
                callTrackSuffix = "Args: [\(parametersList)] = []"
            } else {
                let parametersList =
                    parameters
                    .map { "\($0.firstName.text): \($0.type.description)" }
                    .joined(separator: ", ")
                callTrackSuffix = "Args: [(\(parametersList))] = []"
            }
            var properties: [DeclSyntax] = [
                .init(stringLiteral: "private(set) var \(nameBase)\(callTrackSuffix)")
            ]
            let effectSpecifiers = funcDecl.signature.effectSpecifiers
            if effectSpecifiers?.throwsSpecifier != nil {
                properties.append(.init(stringLiteral: "var \(nameBase)Error: (any Error)?"))
            }
            if effectSpecifiers?.asyncSpecifier != nil {
                properties.append(.init(stringLiteral: "var \(nameBase)Delay: Double?"))
            }
            if let returnType = funcDecl.signature.output?.returnType {
                let type =
                    "\(returnType.description.trimmingCharacters(in: .whitespacesAndNewlines))?"
                properties.append(.init(stringLiteral: "var \(nameBase)Result: \(type)"))
            }
            return properties
        }
    }

}
