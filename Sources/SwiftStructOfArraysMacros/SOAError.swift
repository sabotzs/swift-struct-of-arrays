import SwiftDiagnostics

enum SOAError: Error, DiagnosticMessage {
    case notStruct

    var message: String {
        switch self {
        case .notStruct:
            "SOA macros can be only applied to structs."
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "com.swift-struct-of-arrays", id: message)
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .notStruct:
            .error
        }
    }
}
