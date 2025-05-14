import Foundation

public class FileOpener {
    
    /// Opens a file using the specified editor command
    /// - Parameters:
    ///   - filePath: The path to the file to open
    ///   - editorSettings: The editor settings to use
    /// - Returns: A tuple containing a Bool indicating success and an optional error message
    public static func openFile(at filePath: String, using editorSettings: Configuration.EditorSettings) -> (success: Bool, errorMessage: String?) {
        let process = Process()
        let fullCommand = editorSettings.getFullCommand(for: filePath)
        
        guard !fullCommand.isEmpty else {
            return (false, "No editor command specified")
        }
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = fullCommand
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            // For most editors, we don't want to wait for the process to finish
            // as they'll open in a new window/process
            return (true, nil)
        } catch {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? error.localizedDescription
            return (false, errorMessage)
        }
    }
    
    /// Determine the editor settings to use, with the following precedence:
    /// 1. Provided editorSettings
    /// 2. Default (zed)
    /// - Parameter editorSettings: Optional editor settings to use
    /// - Returns: The editor settings to use
    public static func determineEditorSettings(_ editorSettings: Configuration.EditorSettings?) -> Configuration.EditorSettings {
        if let settings = editorSettings {
            return settings
        }
        
        // Use zed as default
        return Configuration.EditorSettings(command: "zed", arguments: [])
    }
}