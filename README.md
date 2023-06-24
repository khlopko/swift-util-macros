# SweetDeclarations

A set of Swift macros to provide convenient initialization / modification over structs and classes 
declarations.

## Available macros

- `@PublicInit` – generates a public initializer for the type.
- `@GranularUpdate` – generates a public initializer for the type allowing to copy values from 
another instance. 
- `@TestStub` – generates a set of properties (like tracking calls & args, throw custom errors, modify result) for testing stub.
