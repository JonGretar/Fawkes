import Foundation

public struct Configuration: Codable {
    public struct EditorSettings: Codable {
        public var command: String
        public var arguments: [String]

        public init(command: String = "zed", arguments: [String] = []) {
            self.command = command
            self.arguments = arguments
        }

        public func getFullCommand(for filePath: String) -> [String] {
            return [command] + arguments + [filePath]
        }
    }

    public var editor: EditorSettings

    public init(editor: EditorSettings = EditorSettings()) {
        self.editor = editor
    }

    // Get default configuration
    public static var `default`: Configuration {
        return Configuration()
    }

    // Get configuration from standard locations
    public static func fromDefaultLocations() -> Configuration {
        // Use default configuration with 'zed' editor
        return .default
    }
}
