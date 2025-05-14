import Foundation

public struct Configuration: Codable {
    public struct EditorSettings: Codable {
        public var command: String
        public var arguments: [String]

        public init(command: String = "zed", arguments: [String] = ["-g"]) {
            self.command = command
            self.arguments = arguments
        }

        public func getFullCommand(for filePath: String) -> [String] {
            return [command] + arguments + [filePath]
        }
    }

    public struct FileExtensions: Codable {
        public var source: String
        public var test: String

        public init(source: String = "ex", test: String = "exs") {
            self.source = source
            self.test = test
        }
    }

    public struct PathFormats: Codable {
        public var lib: String
        public var test: String
        public var web: String
        public var controllers: String
        public var views: String
        public var live: String
        public var templates: String

        public init(
            lib: String = "lib",
            test: String = "test",
            web: String = "_web",
            controllers: String = "controllers",
            views: String = "views",
            live: String = "live",
            templates: String = "templates"
        ) {
            self.lib = lib
            self.test = test
            self.web = web
            self.controllers = controllers
            self.views = views
            self.live = live
            self.templates = templates
        }
    }

    public var fileExtensions: FileExtensions
    public var pathFormats: PathFormats
    public var editor: EditorSettings

    public init(
        fileExtensions: FileExtensions = FileExtensions(),
        pathFormats: PathFormats = PathFormats(),
        editor: EditorSettings = EditorSettings()
    ) {
        self.fileExtensions = fileExtensions
        self.pathFormats = pathFormats
        self.editor = editor
    }

    // Load configuration from a JSON file
    public static func load(from url: URL) throws -> Configuration {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(Configuration.self, from: data)
    }

    // Save configuration to a JSON file
    public func save(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: url)
    }

    // Get default configuration
    public static var `default`: Configuration {
        return Configuration()
    }

    // Get configuration from standard locations
    public static func fromDefaultLocations() -> Configuration {
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser

        // Look for config in standard locations
        let potentialPaths = [
            // Current directory
            URL(fileURLWithPath: ".fawkes.json"),
            // User home directory
            homeDirectory.appendingPathComponent(".fawkes.json"),
            // XDG config home
            homeDirectory.appendingPathComponent(".config/fawkes/config.json"),
        ]

        for path in potentialPaths {
            if fileManager.fileExists(atPath: path.path) {
                do {
                    return try load(from: path)
                } catch {
                    print(
                        "Warning: Failed to load config from \(path.path): \(error.localizedDescription)"
                    )
                }
            }
        }

        // Fall back to default
        return .default
    }

    // Get editor settings from environment variables
    public static func getEditorFromEnvironment() -> EditorSettings {
        let defaultEditor = EditorSettings()

        if let editorCommand = ProcessInfo.processInfo.environment["EDITOR"] {
            return EditorSettings(command: editorCommand, arguments: [])
        } else if let visualEditor = ProcessInfo.processInfo.environment["VISUAL"] {
            return EditorSettings(command: visualEditor, arguments: [])
        }

        return defaultEditor
    }
}
