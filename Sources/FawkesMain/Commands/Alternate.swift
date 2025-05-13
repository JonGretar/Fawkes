import ArgumentParser
import FawkesLib
import Foundation

struct Alternate: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Go to an alternate file",
        aliases: ["alt"]
    )

    enum Target: String, ExpressibleByArgument {
        case test, controller, model, view, html, live, component, liveComponent, channel, json, task, feature
    }

    @Option(help: "Type of target to visit")
    var target: Target = .test
    
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
        let pathType = AlternatePathType(rawValue: target.rawValue)!
        
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
                // Create editor settings from command line or default
                var editorSettings: Configuration.EditorSettings?
                if let editorCommand = editor {
                    editorSettings = Configuration.EditorSettings(command: editorCommand, arguments: [])
                } else {
                    // Use default settings from config or environment
                    editorSettings = Configuration.fromDefaultLocations().editor
                }
                
                // Open the file
                let (success, errorMessage) = FileOpener.openFile(at: result.path, using: FileOpener.determineEditorSettings(editorSettings))
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