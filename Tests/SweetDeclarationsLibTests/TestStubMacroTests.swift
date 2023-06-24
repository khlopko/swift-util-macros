//
//  TestStubMacroTests.swift
//

import XCTest

import SweetDeclarationsPlugin

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

internal final class TestStubMacroTests: XCTestCase {

    let testMacros: [String: Macro.Type] = [
        "TestStub": TestStubMacro.self,
    ]

    func test_simpleMethods() {
        assertMacroExpansion(
            #"""
            @TestStub
            final class SomeProtocolStub: SomeProtocol {
                func method1() {
                }

                func method2(value: Int) {
                }

                func method3(values: [String]) {
                }

                func method4(value0: Int, value1: [String]) {
                }
            }
            """#,
            expandedSource: #"""
            final class SomeProtocolStub: SomeProtocol {
                func method1() {
                }

                func method2(value: Int) {
                }

                func method3(values: [String]) {
                }

                func method4(value0: Int, value1: [String]) {
                }
                private (set) var method1Calls: Int = 0
                private (set) var method2Args: [Int] = []
                private (set) var method3Args: [[String]] = []
                private (set) var method4Args: [(value0: Int, value1: [String])] = []
            }
            """#,
            macros: testMacros
        )
    }

    func test_throwsMethods() {
        assertMacroExpansion(
            #"""
            @TestStub
            final class SomeProtocolStub: SomeProtocol {
                func method1() throws {
                }
            }
            """#,
            expandedSource: #"""
            final class SomeProtocolStub: SomeProtocol {
                func method1() throws {
                }
                private (set) var method1Calls: Int = 0
                var method1Error: (any Error)?
            }
            """#,
            macros: testMacros
        )
    }

    func test_asyncMethods() {
        assertMacroExpansion(
            #"""
            @TestStub
            final class SomeProtocolStub: SomeProtocol {
                func method1() async {
                }
            }
            """#,
            expandedSource: #"""
            final class SomeProtocolStub: SomeProtocol {
                func method1() async {
                }
                private (set) var method1Calls: Int = 0
                var method1Delay: Double?
            }
            """#,
            macros: testMacros
        )
    }

    func test_resultMethods() {
        assertMacroExpansion(
            #"""
            @TestStub
            final class SomeProtocolStub: SomeProtocol {
                func method1() -> Int {
                }

                func method2() -> [String] {
                }
            }
            """#,
            expandedSource: #"""
            final class SomeProtocolStub: SomeProtocol {
                func method1() -> Int {
                }

                func method2() -> [String] {
                }
                private (set) var method1Calls: Int = 0
                var method1Result: Int?
                private (set) var method2Calls: Int = 0
                var method2Result: [String]?
            }
            """#,
            macros: testMacros
        )
    }

}
