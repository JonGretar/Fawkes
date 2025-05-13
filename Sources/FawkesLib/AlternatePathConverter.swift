import Foundation

public enum AlternatePathType: String, Sendable {
    case test, controller, model, view, html, live, component, liveComponent, channel, json, task, feature
}

public enum ConversionError: Error, LocalizedError, Sendable {
    case invalidPath(String)
    case unsupportedConversion(from: String, to: AlternatePathType)
    
    public var errorDescription: String? {
        switch self {
        case .invalidPath(let path):
            return "Invalid path: \(path). Path must contain a valid filename."
        case .unsupportedConversion(let from, let to):
            return "Cannot convert \(from) to \(to.rawValue) type"
        }
    }
}

public struct ConversionResult: Sendable {
    public let path: String
    public let type: AlternatePathType
    public let originalPath: String
    
    public init(path: String, type: AlternatePathType, originalPath: String) {
        self.path = path
        self.type = type
        self.originalPath = originalPath
    }
}

public struct AlternatePathConverter: Sendable {
    
    public init() {}
    
    public func convertPath(inputPath: String, altType: AlternatePathType) throws -> ConversionResult {
        // Handle paths starting with "./"
        let normalizedPath = inputPath.hasPrefix("./") ? String(inputPath.dropFirst(2)) : inputPath
        
        let pathComponents = normalizedPath.components(separatedBy: "/")
        var outputComponents = pathComponents
        
        // Check if there's a file at the end
        guard !pathComponents.isEmpty, let filename = pathComponents.last, filename.contains(".") else {
            throw ConversionError.invalidPath(inputPath)
        }
        
        // Preserve "./" prefix if it was in the original path
        let prefix = inputPath.hasPrefix("./") ? "./" : ""
        
        switch altType {
        case .test:
            if let _ = pathComponents.firstIndex(of: "lib") {
                outputComponents = convertToTestPath(components: pathComponents)
            } else if let _ = pathComponents.firstIndex(of: "test") {
                outputComponents = convertFromTestPath(components: pathComponents)
            }
            
        case .controller:
            outputComponents = convertToControllerPath(components: pathComponents)
            
        case .model:
            outputComponents = convertToModelPath(components: pathComponents)
            
        case .view:
            outputComponents = convertToViewPath(components: pathComponents)
            
        case .html:
            outputComponents = convertToHtmlPath(components: pathComponents)
            
        case .live:
            outputComponents = convertToLivePath(components: pathComponents)
            
        case .component:
            outputComponents = convertToComponentPath(components: pathComponents)
            
        case .liveComponent:
            outputComponents = convertToLiveComponentPath(components: pathComponents)
            
        case .channel:
            outputComponents = convertToChannelPath(components: pathComponents)
            
        case .json:
            outputComponents = convertToJsonPath(components: pathComponents)
            
        case .task:
            outputComponents = convertToTaskPath(components: pathComponents)
            
        case .feature:
            outputComponents = convertToFeaturePath(components: pathComponents)
        }
        
        let resultPath = prefix + outputComponents.joined(separator: "/")
        return ConversionResult(path: resultPath, type: altType, originalPath: inputPath)
    }
    
    // Helper methods for path conversion
    public func convertToTestPath(components: [String]) -> [String] {
        var result = components
        if let libIndex = components.firstIndex(of: "lib") {
            result[libIndex] = "test"
            
            // Check if this is a web component
            let isWeb = result.contains(where: { $0.hasSuffix("_web") })
            
            // For files in web modules, ensure they're placed in the correct test directory structure
            if isWeb, let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") }) {
                // Check if this is a controller file
                let isController = result.contains("controllers")
                
                // Ensure controller tests go to the controller test directory
                if isController {
                    let appName = result[webIndex].replacingOccurrences(of: "_web", with: "")
                    let _ = [appName + "_web", "controllers"]
                    
                    // Path is already correct, no need to modify it
                }
            }
            
            // Modify the filename to add _test suffix if needed
            let lastIndex = result.count - 1
            if lastIndex >= 0 && result[lastIndex].contains(".") {
                let parts = result[lastIndex].components(separatedBy: ".")
                if parts.count > 1 {
                    let name = parts[0]
                    let _ = parts.dropFirst().joined(separator: ".")
                    if !name.hasSuffix("_test") {
                        // Use .exs for test files by default
                        result[lastIndex] = "\(name)_test.exs"
                    }
                }
            }
        }
        return result
    }
    
    public func convertFromTestPath(components: [String]) -> [String] {
        var result = components
        if let testIndex = components.firstIndex(of: "test") {
            result[testIndex] = "lib"
            
            // Check if this is a web component test
            let isWebTest = result.contains(where: { $0.hasSuffix("_web") })
            
            // For web module tests, ensure they go back to the correct lib structure
            if isWebTest, let _ = result.firstIndex(where: { $0.hasSuffix("_web") }) {
                // Check if this is a controller test
                let isControllerTest = result.contains("controllers")
                
                if isControllerTest {
                    // Already in the correct path format, don't need to change paths
                }
            }
            
            // Remove _test suffix if present and change extension
            let lastIndex = result.count - 1
            if lastIndex >= 0 && result[lastIndex].contains(".") {
                let filename = result[lastIndex]
                if filename.contains("_test.") {
                    // Convert test file extension (.exs) to implementation file extension (.ex)
                    var newFilename = filename.replacingOccurrences(of: "_test.", with: ".")
                    if newFilename.hasSuffix(".exs") {
                        newFilename = newFilename.replacingOccurrences(of: ".exs", with: ".ex")
                    }
                    result[lastIndex] = newFilename
                }
            }
        }
        return result
    }
    
    public func convertToControllerPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module by replacing the app name with web version
                    let webModuleName = "\(appName)_web"
                    
                    // Replace the regular app module with web module
                    result[libIndex + 1] = webModuleName
                    
                    // Add controllers if needed
                    if !result.contains("controllers") {
                        result.insert("controllers", at: libIndex + 2)
                    }
                } else {
                    // Already in web module, just add controllers if not there
                    if !result.contains("controllers") {
                        result.insert("controllers", at: libIndex + 2)
                    }
                }
                
                // Add controller suffix to filename if needed
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    let parts = result[lastIndex].components(separatedBy: ".")
                    if parts.count > 1 && !parts[0].hasSuffix("_controller") {
                        let name = parts[0]
                        let ext = parts.dropFirst().joined(separator: ".")
                        result[lastIndex] = "\(name)_controller.\(ext)"
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToModelPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if in web module - models generally go in the main app module, not web
                let isInWebModule = appName.hasSuffix("_web")
                
                if isInWebModule {
                    // Convert from web module to main app module for models
                    let mainModuleName = appName.replacingOccurrences(of: "_web", with: "")
                    result[libIndex + 1] = mainModuleName
                    
                    // Remove controllers if present
                    if let controllerIndex = result.firstIndex(of: "controllers") {
                        result.remove(at: controllerIndex)
                    }
                }
                
                // Add controller suffix to filename if needed
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    // Remove controller suffix if present
                    let filename = result[lastIndex]
                    if filename.contains("_controller.") {
                        result[lastIndex] = filename.replacingOccurrences(of: "_controller.", with: ".")
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToViewPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module
                    let webModuleName = "\(appName)_web"
                    result.insert(webModuleName, at: libIndex + 2)
                }
                
                // Ensure we have a views directory
                if !result.contains("views") {
                    // Check if we have controllers and replace it
                    if let controllerIndex = result.firstIndex(of: "controllers") {
                        result[controllerIndex] = "views"
                    } else {
                        // Add views after the web module
                        let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") })!
                        result.insert("views", at: webIndex + 1)
                    }
                }
                
                // Update filename to use view naming convention
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    let parts = result[lastIndex].components(separatedBy: ".")
                    if parts.count > 1 {
                        let name = parts[0].replacingOccurrences(of: "_controller", with: "")
                        let ext = parts.dropFirst().joined(separator: ".")
                        if !name.hasSuffix("_view") {
                            result[lastIndex] = "\(name)_view.\(ext)"
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToHtmlPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module
                    let webModuleName = "\(appName)_web"
                    result.insert(webModuleName, at: libIndex + 2)
                }
                
                // Need to navigate to appropriate HTML structure
                // First get the current path context
                let isControllerPath = result.contains("controllers")
                
                if isControllerPath {
                    // If it's a controller, convert to controller's HTML directory
                    if let controllerIndex = result.firstIndex(of: "controllers") {
                        // Get the controller name from filename
                        let lastIndex = result.count - 1
                        if lastIndex >= 0 && result[lastIndex].contains("_controller.") {
                            let controllerName = result[lastIndex]
                                .replacingOccurrences(of: "_controller.ex", with: "")
                            
                            // Replace the controller file with HTML directory structure
                            result.remove(at: lastIndex)
                            result.insert("\(controllerName)_html", at: controllerIndex + 1)
                            
                            // Add a default template name
                            result.append("index.html.heex")
                        }
                    }
                } else {
                    // For other paths, just go to templates directory
                    if result.contains("views") {
                        if let viewIndex = result.firstIndex(of: "views") {
                            result[viewIndex] = "templates"
                            
                            // Update the file extension
                            let lastIndex = result.count - 1
                            if lastIndex >= 0 && result[lastIndex].contains(".") {
                                let filename = result[lastIndex]
                                    .replacingOccurrences(of: "_view.ex", with: "")
                                    .replacingOccurrences(of: ".ex", with: ".html.heex")
                                result[lastIndex] = filename
                            }
                        }
                    } else {
                        // Add templates directory
                        let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") })!
                        result.insert("templates", at: webIndex + 1)
                        
                        // Update the file extension
                        let lastIndex = result.count - 1
                        if lastIndex >= 0 && result[lastIndex].contains(".") {
                            result[lastIndex] = result[lastIndex].replacingOccurrences(of: ".ex", with: ".html.heex")
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToLivePath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module
                    let webModuleName = "\(appName)_web"
                    result.insert(webModuleName, at: libIndex + 2)
                }
                
                // Ensure we have a live directory
                if !result.contains("live") {
                    // Check if we have controllers or views and replace it
                    if let viewIndex = result.firstIndex(of: "views") {
                        result[viewIndex] = "live"
                    } else if let controllerIndex = result.firstIndex(of: "controllers") {
                        result[controllerIndex] = "live"
                    } else {
                        // Add live after the web module
                        let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") })!
                        result.insert("live", at: webIndex + 1)
                    }
                }
                
                // Update filename to use LiveView naming convention
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    let parts = result[lastIndex].components(separatedBy: ".")
                    if parts.count > 1 {
                        let name = parts[0]
                            .replacingOccurrences(of: "_controller", with: "")
                            .replacingOccurrences(of: "_view", with: "")
                        let ext = parts.dropFirst().joined(separator: ".")
                        if !name.hasSuffix("_live") {
                            result[lastIndex] = "\(name)_live.\(ext)"
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToComponentPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module
                    let webModuleName = "\(appName)_web"
                    result.insert(webModuleName, at: libIndex + 2)
                }
                
                // Ensure we have a components directory
                if !result.contains("components") {
                    // Check if we have controllers and replace it
                    if let controllerIndex = result.firstIndex(of: "controllers") {
                        result[controllerIndex] = "components"
                    } else if let viewIndex = result.firstIndex(of: "views") {
                        result[viewIndex] = "components"
                    } else {
                        // Add components after the web module
                        let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") })!
                        result.insert("components", at: webIndex + 1)
                    }
                }
                
                // Update filename if needed
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    let parts = result[lastIndex].components(separatedBy: ".")
                    if parts.count > 1 {
                        let name = parts[0]
                            .replacingOccurrences(of: "_controller", with: "")
                            .replacingOccurrences(of: "_view", with: "")
                            .replacingOccurrences(of: "_component", with: "")
                        let ext = parts.dropFirst().joined(separator: ".")
                        result[lastIndex] = "\(name).\(ext)"
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToLiveComponentPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module
                    let webModuleName = "\(appName)_web"
                    result.insert(webModuleName, at: libIndex + 2)
                }
                
                // Ensure we have a live directory
                if !result.contains("live") {
                    // Check if we have controllers or views and replace it
                    if let viewIndex = result.firstIndex(of: "views") {
                        result[viewIndex] = "live"
                    } else if let controllerIndex = result.firstIndex(of: "controllers") {
                        result[controllerIndex] = "live"
                    } else if let componentIndex = result.firstIndex(of: "components") {
                        result[componentIndex] = "live"
                    } else {
                        // Add live after the web module
                        let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") })!
                        result.insert("live", at: webIndex + 1)
                    }
                }
                
                // Update filename to use component naming convention
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    let parts = result[lastIndex].components(separatedBy: ".")
                    if parts.count > 1 {
                        let name = parts[0]
                            .replacingOccurrences(of: "_controller", with: "")
                            .replacingOccurrences(of: "_view", with: "")
                        let ext = parts.dropFirst().joined(separator: ".")
                        if !name.hasSuffix("_component") {
                            result[lastIndex] = "\(name)_component.\(ext)"
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToChannelPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module
                    let webModuleName = "\(appName)_web"
                    result.insert(webModuleName, at: libIndex + 2)
                }
                
                // Ensure we have a channels directory
                if !result.contains("channels") {
                    // Check if we have controllers and replace it
                    if let controllerIndex = result.firstIndex(of: "controllers") {
                        result[controllerIndex] = "channels"
                    } else if let viewIndex = result.firstIndex(of: "views") {
                        result[viewIndex] = "channels"
                    } else if let liveIndex = result.firstIndex(of: "live") {
                        result[liveIndex] = "channels"
                    } else {
                        // Add channels after the web module
                        let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") })!
                        result.insert("channels", at: webIndex + 1)
                    }
                }
                
                // Update filename to use channel naming convention
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    let parts = result[lastIndex].components(separatedBy: ".")
                    if parts.count > 1 {
                        let name = parts[0]
                            .replacingOccurrences(of: "_controller", with: "")
                            .replacingOccurrences(of: "_view", with: "")
                            .replacingOccurrences(of: "_live", with: "")
                        let ext = parts.dropFirst().joined(separator: ".")
                        if !name.hasSuffix("_channel") {
                            result[lastIndex] = "\(name)_channel.\(ext)"
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToJsonPath(components: [String]) -> [String] {
        var result = components
        
        // Find the application module
        if let libIndex = components.firstIndex(of: "lib") {
            if libIndex + 1 < result.count {
                let appName = result[libIndex + 1]
                
                // Check if we need to go to web module
                let isInWebModule = appName.hasSuffix("_web")
                
                if !isInWebModule {
                    // Convert to web module
                    let webModuleName = "\(appName)_web"
                    result.insert(webModuleName, at: libIndex + 2)
                }
                
                // Ensure we have a controllers directory
                if !result.contains("controllers") {
                    // Add controllers after the web module
                    let webIndex = result.firstIndex(where: { $0.hasSuffix("_web") })!
                    result.insert("controllers", at: webIndex + 1)
                }
                
                // Update filename to use JSON naming convention
                let lastIndex = result.count - 1
                if lastIndex >= 0 && result[lastIndex].contains(".") {
                    let parts = result[lastIndex].components(separatedBy: ".")
                    if parts.count > 1 {
                        // If coming from a controller, remove _controller and add _json
                        let name = parts[0]
                            .replacingOccurrences(of: "_controller", with: "")
                            .replacingOccurrences(of: "_html", with: "")
                        let ext = parts.dropFirst().joined(separator: ".")
                        if !name.hasSuffix("_json") {
                            result[lastIndex] = "\(name)_json.\(ext)"
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    public func convertToTaskPath(components: [String]) -> [String] {
        var result = components
        
        // Tasks are in lib/mix/tasks
        if let libIndex = components.firstIndex(of: "lib") {
            // Ensure the path has mix/tasks
            var hasMix = false
            var hasTasks = false
            
            if libIndex + 1 < result.count && result[libIndex + 1] == "mix" {
                hasMix = true
            }
            
            if hasMix && libIndex + 2 < result.count && result[libIndex + 2] == "tasks" {
                hasTasks = true
            }
            
            // If not in mix/tasks, rebuild the path
            if !hasMix || !hasTasks {
                // Keep everything up to lib, then add mix/tasks
                let prefix = Array(result.prefix(through: libIndex))
                let suffix = result.count > libIndex + 1 ? Array(result.suffix(from: libIndex + 1)) : []
                
                result = prefix + ["mix", "tasks"] + suffix
            }
            
            // No special naming convention for the last component
        }
        
        return result
    }
    
    public func convertToFeaturePath(components: [String]) -> [String] {
        var result = components
        
        // Feature tests are in test/features
        if let testIndex = components.firstIndex(of: "test") {
            // Check if this path already includes features
            var hasFeatures = false
            
            if testIndex + 1 < result.count && result[testIndex + 1] == "features" {
                hasFeatures = true
            }
            
            // If not in features, rebuild the path
            if !hasFeatures {
                // Keep everything up to test, then add features
                let prefix = Array(result.prefix(through: testIndex))
                let suffix = result.count > testIndex + 1 ? Array(result.suffix(from: testIndex + 1)) : []
                
                result = prefix + ["features"] + suffix
            }
            
            // Make sure filename ends with _test.exs
            let lastIndex = result.count - 1
            if lastIndex >= 0 && result[lastIndex].contains(".") {
                let parts = result[lastIndex].components(separatedBy: ".")
                if parts.count > 1 {
                    let name = parts[0]
                    if !name.hasSuffix("_test") {
                        result[lastIndex] = "\(name)_test.exs"
                    }
                }
            }
        } else {
            // If not already in test directory, move to test/features
            result[0] = "test"
            result.insert("features", at: 1)
            
            // Make sure filename ends with _test.exs
            let lastIndex = result.count - 1
            if lastIndex >= 0 && result[lastIndex].contains(".") {
                let parts = result[lastIndex].components(separatedBy: ".")
                if parts.count > 1 {
                    let name = parts[0]
                    if !name.hasSuffix("_test") {
                        result[lastIndex] = "\(name)_test.exs"
                    } else {
                        result[lastIndex] = "\(name).exs"
                    }
                }
            }
        }
        
        return result
    }
}