//
//  DebugMsg.swift
//

import Foundation
import SwiftDiagnostics

struct DebugMsg: DiagnosticMessage {
    var message: String
    var diagnosticID: MessageID = .init(domain: "debug", id: UUID().uuidString)
    var severity: DiagnosticSeverity = .warning
}
