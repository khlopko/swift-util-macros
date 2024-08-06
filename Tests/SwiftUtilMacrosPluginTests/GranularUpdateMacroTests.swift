//
//  GranularUpdateMacroTests.swift
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftUtilMacrosPlugin
import XCTest

internal final class GranularUpdateMacroTests: XCTestCase {

    let testMacros: [String: Macro.Type] = [
        "GranularUpdate": GranularUpdateMacro.self
    ]

    func test_forStruct() {
        assertMacroExpansion(
            #"""
            @GranularUpdate
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
                        from another: User,
                        id: String? = nil,
                        name: String? = nil
                    ) {
                        self.id = id ?? another.id
                        self.name = name ?? another.name
                    }
                }
                """#,
            macros: testMacros
        )
    }

    func test_forClass() {
        assertMacroExpansion(
            #"""
            @GranularUpdate
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
                        from another: User,
                        id: String? = nil,
                        name: String? = nil
                    ) {
                        self.id = id ?? another.id
                        self.name = name ?? another.name
                    }
                }
                """#,
            macros: testMacros
        )
    }

    func test_handlesClosures() {
        // assume we have declaration eariler like following:
        // public typealias GetPublications = () -> [String]
        assertMacroExpansion(
            #"""
            @GranularUpdate
            public class User {
                public let id: String
                public let getName: () -> String
                public let getPublications: GetPublications
            }
            """#,
            expandedSource:
                #"""
                public class User {
                    public let id: String
                    public let getName: () -> String
                    public let getPublications: GetPublications

                    public init(
                        from another: User,
                        id: String? = nil,
                        getName: (() -> String)? = nil,
                        getPublications: GetPublications? = nil
                    ) {
                        self.id = id ?? another.id
                        self.getName = getName ?? another.getName
                        self.getPublications = getPublications ?? another.getPublications
                    }
                }
                """#,
            macros: testMacros
        )
    }

}
