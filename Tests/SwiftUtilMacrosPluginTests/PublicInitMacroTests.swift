//
//  PublicInitMacroTests.swift
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftUtilMacrosPlugin
import XCTest

internal final class PublicInitMacroTests: XCTestCase {

    let testMacros: [String: Macro.Type] = [
        "PublicInit": PublicInitMacro.self
    ]

    func test_forStruct() {
        assertMacroExpansion(
            #"""
            @PublicInit
            public struct User {
                public let id: String
                public let name: String
            }
            """#,
            expandedSource:
                #"""
                public struct User {
                    public let id: String
                    public let name: String

                    public init(
                        id: String,
                        name: String
                    ) {
                        self.id = id
                        self.name = name
                    }
                }
                """#,
            macros: testMacros
        )
    }

    func test_forClass() {
        assertMacroExpansion(
            #"""
            @PublicInit
            public class User {
                public let id: String
                public let name: String
            }
            """#,
            expandedSource:
                #"""
                public class User {
                    public let id: String
                    public let name: String

                    public init(
                        id: String,
                        name: String
                    ) {
                        self.id = id
                        self.name = name
                    }
                }
                """#,
            macros: testMacros
        )
    }

    func test_optionals() {
        assertMacroExpansion(
            #"""
            @PublicInit
            public struct User {
                public let id: String
                public let name: String
                public let publications: [String]?
            }
            """#,
            expandedSource: #"""
                public struct User {
                    public let id: String
                    public let name: String
                    public let publications: [String]?

                    public init(
                        id: String,
                        name: String,
                        publications: [String]?
                    ) {
                        self.id = id
                        self.name = name
                        self.publications = publications
                    }
                }
                """#,
            macros: testMacros
        )
    }

    func test_withClosures() {
        assertMacroExpansion(
            #"""
            @PublicInit
            public struct User {
                public let id: String
                public let getName: () -> String
            }
            """#,
            expandedSource:
                #"""
                public struct User {
                    public let id: String
                    public let getName: () -> String

                    public init(
                        id: String,
                        getName: @escaping () -> String
                    ) {
                        self.id = id
                        self.getName = getName
                    }
                }
                """#,
            macros: testMacros
        )
    }

    func test_withOptionalClosures() {
        assertMacroExpansion(
            #"""
            @PublicInit
            public struct User {
                public let id: String
                public let getName: (() -> String)?
            }
            """#,
            expandedSource:
                #"""
                public struct User {
                    public let id: String
                    public let getName: (() -> String)?

                    public init(
                        id: String,
                        getName: (() -> String)?
                    ) {
                        self.id = id
                        self.getName = getName
                    }
                }
                """#,
            macros: testMacros
        )
    }

    func test_explicitTypeIsRequired() {
        assertMacroExpansion(
            #"""
            @PublicInit
            public struct User {
                public var id = "default_id"
                public let name: String
            }
            """#,
            expandedSource: #"""
                public struct User {
                    public var id = "default_id"
                    public let name: String

                    public init(
                        name: String
                    ) {
                        self.name = name
                    }
                }
                """#,
            diagnostics: [
                DiagnosticSpec(
                    message:
                        "Property type not found or not supported. Specify type explicitly if its missing to fix this error",
                    line: 3,
                    column: 5
                )
            ],
            macros: testMacros
        )
    }

    func test_ignoresComputedProperties() {
        assertMacroExpansion(
            #"""
            @PublicInit
            public struct User {
                public var descr: String { "\(id)+\(name)" }
                public let id: String
                public let name: String
            }
            """#,
            expandedSource:
                #"""
                public struct User {
                    public var descr: String { "\(id)+\(name)" }
                    public let id: String
                    public let name: String

                    public init(
                        id: String,
                        name: String
                    ) {
                        self.id = id
                        self.name = name
                    }
                }
                """#,
            macros: testMacros
        )
    }
}
