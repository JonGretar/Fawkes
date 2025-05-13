import Foundation
import OSLog

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public enum LogLevel: Int, Comparable, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public final class Logger: @unchecked Sendable {
    private let logger: OSLog
    private let subsystem: String
    public let minLevel: LogLevel
    
    public init(subsystem: String = "com.jongretar.fawkes", category: String = "default", minLevel: LogLevel = .info) {
        self.subsystem = subsystem
        self.logger = OSLog(subsystem: subsystem, category: category)
        self.minLevel = minLevel
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: Int) {
        guard level >= minLevel else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        switch level {
        case .debug:
            os_log("%{public}@", log: logger, type: .debug, logMessage)
        case .info:
            os_log("%{public}@", log: logger, type: .info, logMessage)
        case .warning:
            os_log("%{public}@", log: logger, type: .default, logMessage)
        case .error:
            os_log("%{public}@", log: logger, type: .error, logMessage)
        }
        
        // Also print to console in non-release builds
        #if DEBUG
        let levelString = ["DEBUG", "INFO", "WARNING", "ERROR"][level.rawValue]
        print("[\(levelString)] \(logMessage)")
        #endif
    }
    
    // Global shared logger
    @MainActor public static let shared = Logger()
}

// Convenience global functions
@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
@MainActor public func debugLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.debug(message, file: file, function: function, line: line)
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
@MainActor public func infoLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.info(message, file: file, function: function, line: line)
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
@MainActor public func warningLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.warning(message, file: file, function: function, line: line)
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
@MainActor public func errorLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.error(message, file: file, function: function, line: line)
}