import Foundation

/// A utility class for transforming paths and naming patterns in Elixir projects
public struct PathTransformer: Sendable {
    
    /// Transform a string to snake_case
    /// - Parameter input: The input string
    /// - Returns: The snake_case version of the string
    public static func toSnakeCase(_ input: String) -> String {
        guard !input.isEmpty else { return "" }
        
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let range = NSRange(location: 0, length: input.utf16.count)
        let snakeCaseString = regex?.stringByReplacingMatches(
            in: input,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        ).lowercased() ?? input.lowercased()
        
        return snakeCaseString
    }
    
    /// Transform a string to CamelCase
    /// - Parameter input: The input string (typically snake_case)
    /// - Returns: The CamelCase version of the string
    public static func toCamelCase(_ input: String) -> String {
        let parts = input.components(separatedBy: "_")
        
        let camelCase = parts.enumerated().map { index, part in
            if index == 0 {
                return part.lowercased()
            } else {
                return part.prefix(1).uppercased() + part.dropFirst().lowercased()
            }
        }.joined()
        
        return camelCase
    }
    
    /// Transform a string to PascalCase (capitalized camelCase)
    /// - Parameter input: The input string (typically snake_case)
    /// - Returns: The PascalCase version of the string
    public static func toPascalCase(_ input: String) -> String {
        let parts = input.components(separatedBy: "_")
        
        let pascalCase = parts.map { part in
            part.prefix(1).uppercased() + part.dropFirst().lowercased()
        }.joined()
        
        return pascalCase
    }
    
    /// Format a string to represent an Elixir module name
    /// - Parameter input: The input string, typically a path component
    /// - Returns: The properly formatted Elixir module name
    public static func toElixirModule(_ input: String) -> String {
        return toPascalCase(input)
    }
    
    /// Convert a path to an Elixir module name
    /// - Parameter path: The file path to convert
    /// - Returns: The corresponding Elixir module name
    public static func pathToModuleName(_ path: String) -> String {
        let components = path.components(separatedBy: "/")
        
        // Find the lib or test directory index
        guard let rootIndex = components.firstIndex(where: { $0 == "lib" || $0 == "test" }),
              rootIndex + 1 < components.count else {
            return ""
        }
        
        // Extract the module parts
        var moduleParts: [String] = []
        
        // Add the app name (properly formatted)
        let appName = components[rootIndex + 1]
        if appName.hasSuffix("_web") {
            moduleParts.append(toPascalCase(String(appName.dropLast(4))) + "Web")
        } else {
            moduleParts.append(toPascalCase(appName))
        }
        
        // Add any additional subdirectory components
        if components.count > rootIndex + 2 {
            for i in (rootIndex + 2)..<(components.count - 1) {
                if !["controllers", "views", "channels", "live", "components"].contains(components[i]) {
                    moduleParts.append(toPascalCase(components[i]))
                }
            }
        }
        
        // Extract the filename without extension
        if let filename = components.last, filename.contains(".") {
            let nameWithoutExt = filename.components(separatedBy: ".")[0]
            
            // Handle special suffixes
            let suffixes = ["_controller", "_view", "_channel", "_component", "_live", "_html", "_json"]
            var baseName = nameWithoutExt
            var suffix = ""
            
            for potentialSuffix in suffixes {
                if nameWithoutExt.hasSuffix(potentialSuffix) {
                    baseName = String(nameWithoutExt.dropLast(potentialSuffix.count))
                    suffix = potentialSuffix
                    break
                }
            }
            
            // Add the base name
            moduleParts.append(toPascalCase(baseName))
            
            // Add the suffix in proper format if needed
            if !suffix.isEmpty {
                let formattedSuffix = toPascalCase(String(suffix.dropFirst())) // Drop the leading underscore
                moduleParts[moduleParts.count - 1] += formattedSuffix
            }
        }
        
        return moduleParts.joined(separator: ".")
    }
    
    /// Convert a module name to a file path
    /// - Parameters:
    ///   - moduleName: The Elixir module name
    ///   - rootDir: The root directory ("lib" or "test")
    ///   - fileExtension: The file extension to use
    /// - Returns: The corresponding file path
    public static func moduleNameToPath(
        _ moduleName: String,
        rootDir: String = "lib",
        fileExtension: String = "ex"
    ) -> String {
        let moduleComponents = moduleName.components(separatedBy: ".")
        
        guard !moduleComponents.isEmpty else { return "" }
        
        var pathComponents: [String] = [rootDir]
        
        // Handle main app module (possible Web suffix)
        if moduleComponents[0].hasSuffix("Web") {
            let appName = String(moduleComponents[0].dropLast(3))
            pathComponents.append(toSnakeCase(appName) + "_web")
        } else {
            pathComponents.append(toSnakeCase(moduleComponents[0]))
        }
        
        // Add remaining components
        if moduleComponents.count > 2 {
            for i in 1...(moduleComponents.count - 2) {
                pathComponents.append(toSnakeCase(moduleComponents[i]))
            }
        }
        
        // Handle the last component, which might need special treatment
        if moduleComponents.count > 1 {
            let lastComponent = moduleComponents.last!
            
            // Check for special suffixes
            let suffixPatterns: [(suffix: String, directory: String)] = [
                ("Controller", "controllers"),
                ("View", "views"),
                ("Channel", "channels"),
                ("Component", "components"),
                ("Live", "live"),
                ("HTML", "controllers"),
                ("JSON", "controllers")
            ]
            
            var baseComponent = lastComponent
            var suffixDir: String? = nil
            var fileSuffix = ""
            
            for (suffix, directory) in suffixPatterns {
                if lastComponent.hasSuffix(suffix) {
                    baseComponent = String(lastComponent.dropLast(suffix.count))
                    suffixDir = directory
                    fileSuffix = "_" + suffix.lowercased()
                    break
                }
            }
            
            // Add the directory if we found a suffix
            if let dir = suffixDir, !pathComponents.contains(dir) {
                // Insert the directory at the appropriate position
                pathComponents.insert(dir, at: 2)
            }
            
            // Add special handling for HTML and JSON
            if fileSuffix == "_html" {
                // HTML files go in controllers/name_html.ex
                // We don't need to do anything special here since the directory is already added
            }
            
            // Build the final filename
            let filename = toSnakeCase(baseComponent) + fileSuffix + "." + fileExtension
            pathComponents.append(filename)
        }
        
        return pathComponents.joined(separator: "/")
    }
}