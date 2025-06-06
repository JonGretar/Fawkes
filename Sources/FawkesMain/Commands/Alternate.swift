import ArgumentParser
import FawkesLib
import Foundation

struct Alternate: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Go to an alternate file",
        aliases: ["alt"]
    )

    enum Target: String, ExpressibleByArgument, CaseIterable {
        case test, controller, model, view, html, live, component, liveComponent, channel, json, task, feature
    
        // Displays a list of available targets and handles user selection with interactive menu
        static func selectTargetInteractively(forPath path: String, checkFileExists: Bool) throws -> AlternatePathType {
            let converter = AlternatePathConverter()
            let validTargets = converter.getValidTargets(forPath: path, checkFileExists: checkFileExists)
            
            // Convert AlternatePathType to Target
            let targetOptions = validTargets.map { Target(rawValue: $0.rawValue)! }
            
            // Check which files exist for display purposes
            var fileExistsMap: [AlternatePathType: Bool] = [:]
            for target in validTargets {
                do {
                    let result = try converter.convertPath(inputPath: path, altType: target)
                    fileExistsMap[target] = FileManager.default.fileExists(atPath: result.path)
                } catch {
                    fileExistsMap[target] = false
                }
            }
            
            // Prepare menu items with indicators for file existence
            var menuItems: [String] = []
            for targetOption in targetOptions {
                let targetType = AlternatePathType(rawValue: targetOption.rawValue)!
                let fileExists = fileExistsMap[targetType] ?? false
                let createIndicator = (!fileExists) ? " (create new)" : ""
                menuItems.append("\(targetOption.rawValue)\(createIndicator)")
            }
            
            // Create and show the interactive terminal menu
            let menu = TerminalMenu(items: menuItems, prompt: "Available targets for \(path):")
            let result = menu.show()
            
            // Handle the menu result
            switch result {
            case .selected(let index):
                let selectedTarget = targetOptions[index]
                print("Selected target: \(selectedTarget.rawValue)")
                return AlternatePathType(rawValue: selectedTarget.rawValue)!
                
            case .cancelled:
                print("Selection cancelled, defaulting to test")
                return .test
            }
        }
    }

    @Option(help: "Type of target to visit. If not specified, a list of targets will be shown for selection.")
    var target: Target?
    
    @Argument(help: "The input file path to convert")
    var inputPath: String
    
    @Flag(name: .long, help: "Show details about the conversion")
    var verbose: Bool = false
    
    @Flag(name: .long, help: "Create the target file if it doesn't exist")
    var create: Bool = false
    
    @Flag(name: .long, help: "Skip template generation when creating files")
    var skipTemplate: Bool = false
    
    @Flag(name: .long, help: "Output the template that would be used to create the file")
    var showTemplate: Bool = false
    
    @Flag(name: .long, help: "Open the resulting file in an editor")
    var open: Bool = false
    
    @Option(name: .long, help: "Editor command to use when opening files (overrides config and environment)")
    var editor: String?
    
    func run() throws {
        let converter = AlternatePathConverter()
        
        // If no target is specified, display a list and prompt for selection
        let pathType: AlternatePathType
        if let selectedTarget = target {
            pathType = AlternatePathType(rawValue: selectedTarget.rawValue)!
        } else {
            // Only check file existence when --create is false
            pathType = try Target.selectTargetInteractively(forPath: inputPath, checkFileExists: !create)
        }
        
        do {
            let result = try converter.convertPath(inputPath: inputPath, altType: pathType)
            
            if verbose {
                print("Converting \(result.originalPath) to \(result.type.rawValue) type")
                print("Result: \(result.path)")
            } else {
                print(result.path)
            }
            
            // Handle file creation if requested
            if create || showTemplate {
                let templateGenerator = TemplateGenerator()
                let template = templateGenerator.generateTemplate(forPath: result.path, type: result.type)
                
                if showTemplate {
                    print("\nTemplate:")
                    print(template)
                }
                
                if create && !showTemplate {
                    // Check if file exists
                    let fileManager = FileManager.default
                    let fileURL = URL(fileURLWithPath: result.path)
                    
                    if !fileManager.fileExists(atPath: result.path) {
                        // Create directory structure if needed
                        try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), 
                                                       withIntermediateDirectories: true)
                        
                        // Create the file with template content by default, unless skip-template is specified
                        if self.skipTemplate {
                            try "".write(to: fileURL, atomically: true, encoding: .utf8)
                            print("Created empty file: \(result.path)")
                        } else {
                            try template.write(to: fileURL, atomically: true, encoding: .utf8)
                            print("Created file: \(result.path)")
                        }
                    } else {
                        print("File already exists: \(result.path)")
                    }
                }
            }
            
            // Handle file opening if requested
            if open {
                // Create editor settings from command line or default to zed
                var editorSettings: Configuration.EditorSettings
                if let editorCommand = editor {
                    editorSettings = Configuration.EditorSettings(command: editorCommand, arguments: [])
                } else {
                    // Use default settings (zed)
                    editorSettings = Configuration.EditorSettings()
                }
                
                // Open the file
                let (success, errorMessage) = FileOpener.openFile(at: result.path, using: editorSettings)
                if !success, let error = errorMessage {
                    print("Failed to open file: \(error)")
                } else if success && verbose {
                    print("Opened file in editor: \(result.path)")
                }
            }
        } catch let error as ConversionError {
            print("Error: \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("Unexpected error: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
}