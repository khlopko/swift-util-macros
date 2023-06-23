//
//  SweetDeclarationsPlugin.swift
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SweetDeclarationsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GranularUpdateMacro.self,
        PublicInitMacro.self
    ]
}
