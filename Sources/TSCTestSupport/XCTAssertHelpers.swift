/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest

import TSCBasic
import TSCUtility

#if os(macOS)
import class Foundation.Bundle
#endif

public func XCTAssertFileExists(_ path: AbsolutePath, file: StaticString = #file, line: UInt = #line) {
    if !localFileSystem.isFile(path) {
        XCTFail("Expected file doesn't exist: \(path)", file: file, line: line)
    }
}

public func XCTAssertDirectoryExists(_ path: AbsolutePath, file: StaticString = #file, line: UInt = #line) {
    if !localFileSystem.isDirectory(path) {
        XCTFail("Expected directory doesn't exist: \(path)", file: file, line: line)
    }
}

public func XCTAssertNoSuchPath(_ path: AbsolutePath, file: StaticString = #file, line: UInt = #line) {
    if localFileSystem.exists(path) {
        XCTFail("path exists but should not: \(path)", file: file, line: line)
    }
}

public func XCTAssertThrows<T: Swift.Error>(
    _ expectedError: T,
    file: StaticString = #file,
    line: UInt = #line,
    _ body: () throws -> Void
) where T: Equatable {
    do {
        try body()
        XCTFail("body completed successfully", file: file, line: line)
    } catch let error as T {
        XCTAssertEqual(error, expectedError, file: file, line: line)
    } catch {
        XCTFail("unexpected error thrown", file: file, line: line)
    }
}

public func XCTAssertThrows<T: Swift.Error, Ignore>(
    _ expression: @autoclosure () throws -> Ignore,
    file: StaticString = #file,
    line: UInt = #line,
    _ errorHandler: (T) -> Bool
) {
    do {
        let result = try expression()
        XCTFail("body completed successfully: \(result)", file: file, line: line)
    } catch let error as T {
        XCTAssertTrue(errorHandler(error), "Error handler returned false")
    } catch {
        XCTFail("unexpected error thrown", file: file, line: line)
    }
}

public func XCTNonNil<T>(
   _ optional: T?,
   file: StaticString = #file,
   line: UInt = #line,
   _ body: (T) throws -> Void
) {
    guard let optional = optional else {
        return XCTFail("Unexpected nil value", file: file, line: line)
    }
    do {
        try body(optional)
    } catch {
        XCTFail("Unexpected error \(error)", file: file, line: line)
    }
}

public func XCTAssertNoDiagnostics(_ engine: DiagnosticsEngine, file: StaticString = #file, line: UInt = #line) {
    let diagnostics = engine.diagnostics
    if diagnostics.isEmpty { return }
    let diags = engine.diagnostics.map({ "- " + $0.description }).joined(separator: "\n")
    XCTFail("Found unexpected diagnostics: \n\(diags)", file: file, line: line)
}
