import SwiftDiagnostics

enum SOAError: Error, DiagnosticMessage {
    case notStruct
    case noMemberVariables

    var message: String {
        switch self {
        case .notStruct:
            "SOA macros can be only applied to structs."
        case .noMemberVariables:
            "SOA macros can be only applied to structs with at least one member variable."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "com.swift-struct-of-arrays", id: message)
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .notStruct, .noMemberVariables:
            .error
        }
    }
}
