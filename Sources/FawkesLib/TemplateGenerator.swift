import Foundation

/// A struct to generate templates for Elixir files
public struct TemplateGenerator: Sendable {
    
    /// Configuration for template generation
    public struct Configuration: Sendable, Codable {
        public var moduleSuffix: Bool
        public var includeUse: Bool
        public var includeModuleDoc: Bool
        
        public init(moduleSuffix: Bool = true, includeUse: Bool = true, includeModuleDoc: Bool = false) {
            self.moduleSuffix = moduleSuffix
            self.includeUse = includeUse
            self.includeModuleDoc = includeModuleDoc
        }
    }
    
    public let config: Configuration
    
    public init(config: Configuration = Configuration()) {
        self.config = config
    }
    
    /// Generates a template for a given file path and type
    /// - Parameters:
    ///   - path: The file path to generate template for
    ///   - type: The type of file to generate
    /// - Returns: The template content as a string
    public func generateTemplate(forPath path: String, type: AlternatePathType) -> String {
        let components = path.components(separatedBy: "/")
        guard !components.isEmpty else { return "" }
        
        // Extract module name components
        let (appName, moduleName) = extractModuleInfo(fromPath: path)
        
        // Generate the appropriate template
        switch type {
        case .controller:
            return generateControllerTemplate(appName: appName, moduleName: moduleName)
        case .model:
            return generateModelTemplate(appName: appName, moduleName: moduleName)
        case .view:
            return generateViewTemplate(appName: appName, moduleName: moduleName)
        case .test:
            return generateTestTemplate(appName: appName, moduleName: moduleName, path: path)
        case .component:
            return generateComponentTemplate(appName: appName, moduleName: moduleName)
        case .live:
            return generateLiveViewTemplate(appName: appName, moduleName: moduleName)
        case .liveComponent:
            return generateLiveComponentTemplate(appName: appName, moduleName: moduleName)
        case .html:
            return generateHtmlTemplate(appName: appName, moduleName: moduleName)
        case .json:
            return generateJsonTemplate(appName: appName, moduleName: moduleName)
        case .channel:
            return generateChannelTemplate(appName: appName, moduleName: moduleName)
        case .task:
            return generateTaskTemplate(appName: appName, moduleName: moduleName)
        case .feature:
            return generateFeatureTemplate(appName: appName, moduleName: moduleName)
        }
    }
    
    /// Extracts module information from a file path
    /// - Parameter path: The file path to extract from
    /// - Returns: A tuple containing (appName, moduleName)
    private func extractModuleInfo(fromPath path: String) -> (String, String) {
        let components = path.components(separatedBy: "/")
        
        // Find lib or test index
        guard let libOrTestIndex = components.firstIndex(where: { $0 == "lib" || $0 == "test" }),
              libOrTestIndex + 1 < components.count else {
            return ("", "")
        }
        
        // Extract app name
        let rawAppName = components[libOrTestIndex + 1]
        let appName = rawAppName.hasSuffix("_web") ? 
            String(rawAppName.dropLast(4)).capitalized : rawAppName.capitalized
        
        // Extract module name from filename
        if let filename = components.last, filename.contains(".") {
            let nameComponents = filename.components(separatedBy: ".")
            if nameComponents.count > 1 {
                var moduleName = nameComponents[0]
                
                // Remove suffixes like _controller, _view, etc.
                let suffixes = ["_controller", "_view", "_component", "_channel", "_live", "_html", "_json", "_test"]
                for suffix in suffixes where moduleName.hasSuffix(suffix) {
                    moduleName = String(moduleName.dropLast(suffix.count))
                }
                
                return (appName, toCapitalizedCamelCase(moduleName))
            }
        }
        
        // If no filename with extension, use the last path component
        if components.count > libOrTestIndex + 2 {
            return (appName, toCapitalizedCamelCase(components.last ?? ""))
        }
        
        return (appName, "")
    }
    
    /// Converts a snake_case string to CamelCase
    /// - Parameter input: The snake_case string
    /// - Returns: The CamelCase string
    private func toCapitalizedCamelCase(_ input: String) -> String {
        let parts = input.components(separatedBy: "_")
        let camelCaseParts = parts.map { $0.prefix(1).uppercased() + $0.dropFirst() }
        return camelCaseParts.joined()
    }
    
    // MARK: - Template Generators
    
    private func generateControllerTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            Controller for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use \(appName)Web, :controller\n" : ""
        
        return """
        defmodule \(appName)Web.\(moduleName)Controller do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateModelTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            Schema for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use Ecto.Schema\n  import Ecto.Changeset\n" : ""
        
        return """
        defmodule \(appName).\(moduleName) do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateViewTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            View for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use \(appName)Web, :view\n" : ""
        
        return """
        defmodule \(appName)Web.\(moduleName)View do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateTestTemplate(appName: String, moduleName: String, path: String) -> String {
        let isControllerTest = path.contains("/controllers/")
        let isChannelTest = path.contains("/channels/")
        let isLiveTest = path.contains("/live/")
        let isComponentTest = path.contains("/components/")
        let isFeatureTest = path.contains("/features/")
        
        var useStatement = "  use ExUnit.Case"
        var aliasStatement = ""
        
        if isControllerTest {
            useStatement = "  use \(appName)Web.ConnCase"
            aliasStatement = "\n\n  alias \(appName)Web.\(moduleName)Controller"
        } else if isChannelTest {
            useStatement = "  use \(appName)Web.ChannelCase"
            aliasStatement = "\n\n  alias \(appName)Web.\(moduleName)Channel"
        } else if isLiveTest {
            useStatement = "  use \(appName)Web.ConnCase"
            aliasStatement = "\n\n  import Phoenix.LiveViewTest"
            
            if path.contains("_component_test") {
                aliasStatement += "\n  alias \(appName)Web.\(moduleName)Component"
            } else {
                aliasStatement += "\n  alias \(appName)Web.\(moduleName)Live"
            }
        } else if isComponentTest {
            useStatement = "  use \(appName)Web.ConnCase"
            aliasStatement = "\n\n  alias \(appName)Web.\(moduleName)"
        } else if isFeatureTest {
            useStatement = "  use \(appName)Web.FeatureCase"
        } else {
            aliasStatement = "\n\n  alias \(appName).\(moduleName)"
        }
        
        useStatement += ", async: true"
        
        return """
        defmodule \(appName)Web.\(moduleName)Test do
        \(useStatement)\(aliasStatement)
        end
        """
    }
    
    private func generateComponentTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            Component for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use Phoenix.Component\n" : ""
        
        return """
        defmodule \(appName)Web.\(moduleName) do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateLiveViewTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            LiveView for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use \(appName)Web, :live_view\n" : ""
        
        return """
        defmodule \(appName)Web.\(moduleName)Live do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateLiveComponentTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            LiveComponent for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use \(appName)Web, :live_component\n" : ""
        
        return """
        defmodule \(appName)Web.\(moduleName)Component do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateHtmlTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            HTML for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use \(appName)Web, :html\n\n  embed_templates \"\(moduleName.lowercased())_html/*\"\n" : ""
        
        return """
        defmodule \(appName)Web.\(moduleName)HTML do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateJsonTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            JSON for \(moduleName)
            \"\"\"
            
            """ : ""
        
        return """
        defmodule \(appName)Web.\(moduleName)JSON do
        \(moduleDoc)
        end
        """
    }
    
    private func generateChannelTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            Channel for \(moduleName)
            \"\"\"
            
            """ : ""
        
        let useStatement = config.includeUse ? 
            "  use \(appName)Web, :channel\n" : ""
        
        return """
        defmodule \(appName)Web.\(moduleName)Channel do
        \(moduleDoc)\(useStatement)
        end
        """
    }
    
    private func generateTaskTemplate(appName: String, moduleName: String) -> String {
        let moduleDoc = config.includeModuleDoc ? 
            """
            @moduledoc \"\"\"
            Mix task for \(moduleName)
            \"\"\"
            
            """ : ""
        
        return """
        defmodule Mix.Tasks.\(moduleName) do
          use Mix.Task
        
          @shortdoc "\(moduleName) task"
        \(moduleDoc)
          @impl true
          @doc false
          def run(argv) do
            
          end
        end
        """
    }
    
    private func generateFeatureTemplate(appName: String, moduleName: String) -> String {
        return """
        defmodule \(appName)Web.\(moduleName)Test do
          use \(appName)Web.FeatureCase, async: true
        end
        """
    }
}