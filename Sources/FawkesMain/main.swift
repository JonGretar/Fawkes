import ArgumentParser
import FawkesLib
import Foundation

struct FawkesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Helpful commands for elixir development",
        subcommands: [Alternate.self],
        // Add shell completion subcommand
        helpNames: [.long, .short]
    )
    
    @Flag(name: .customLong("generate-completion-script"),
          help: "Generate shell completion script")
    var generateCompletionScript = false
    
    @Option(name: .customLong("shell"),
            help: "Shell type for completion script (bash, zsh, fish)")
    var shell = "bash"
    
    func run() throws {
        if generateCompletionScript {
            var script: String = ""
            switch shell.lowercased() {
            case "bash":
                script = FawkesCommand.completionScript(for: .bash)
            case "zsh":
                script = FawkesCommand.completionScript(for: .zsh)
            case "fish":
                script = FawkesCommand.completionScript(for: .fish)
            default:
                print("Unsupported shell: \(shell)")
                throw ExitCode.failure
            }
            print(script)
        }
    }
}

FawkesCommand.main()