import XCTest
@testable import FawkesLib

final class TemplateGeneratorTests: XCTestCase {
    
    // Test fixture
    let generator = TemplateGenerator()
    
    func testControllerTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/controllers/user_controller.ex", 
            type: .controller
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserController do"))
        XCTAssertTrue(template.contains("use MyAppWeb, :controller"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testModelTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app/user.ex", 
            type: .model
        )
        
        XCTAssertTrue(template.contains("defmodule MyApp.User do"))
        XCTAssertTrue(template.contains("use Ecto.Schema"))
        XCTAssertTrue(template.contains("import Ecto.Changeset"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testViewTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/views/user_view.ex", 
            type: .view
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserView do"))
        XCTAssertTrue(template.contains("use MyAppWeb, :view"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testLiveViewTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/live/user_live.ex", 
            type: .live
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserLive do"))
        XCTAssertTrue(template.contains("use MyAppWeb, :live_view"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testComponentTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/components/user.ex", 
            type: .component
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.User do"))
        XCTAssertTrue(template.contains("use Phoenix.Component"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testLiveComponentTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/live/user_component.ex", 
            type: .liveComponent
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserComponent do"))
        XCTAssertTrue(template.contains("use MyAppWeb, :live_component"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testHtmlTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/controllers/user_html.ex", 
            type: .html
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserHTML do"))
        XCTAssertTrue(template.contains("use MyAppWeb, :html"))
        XCTAssertTrue(template.contains("embed_templates \"user_html/*\""))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testJsonTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/controllers/user_json.ex", 
            type: .json
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserJSON do"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testChannelTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/my_app_web/channels/user_channel.ex", 
            type: .channel
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserChannel do"))
        XCTAssertTrue(template.contains("use MyAppWeb, :channel"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testTaskTemplate() {
        let template = generator.generateTemplate(
            forPath: "lib/mix/tasks/import_users.ex", 
            type: .task
        )
        
        XCTAssertTrue(template.contains("defmodule Mix.Tasks.ImportUsers do"))
        XCTAssertTrue(template.contains("use Mix.Task"))
        XCTAssertTrue(template.contains("@shortdoc \"ImportUsers task\""))
        XCTAssertTrue(template.contains("@impl true"))
        XCTAssertTrue(template.contains("def run(argv) do"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testFeatureTemplate() {
        let template = generator.generateTemplate(
            forPath: "test/features/user_registration_test.exs", 
            type: .feature
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserRegistrationTest do"))
        XCTAssertTrue(template.contains("use MyAppWeb.FeatureCase, async: true"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testTestTemplate() {
        let template = generator.generateTemplate(
            forPath: "test/my_app/user_test.exs", 
            type: .test
        )
        
        XCTAssertTrue(template.contains("defmodule MyApp.UserTest do"))
        XCTAssertTrue(template.contains("use ExUnit.Case, async: true"))
        XCTAssertTrue(template.contains("alias MyApp.User"))
        XCTAssertTrue(template.contains("end"))
    }
    
    func testCustomConfiguration() {
        let config = TemplateGenerator.Configuration(
            moduleSuffix: false,
            includeUse: false,
            includeModuleDoc: true
        )
        
        let customGenerator = TemplateGenerator(config: config)
        
        let template = customGenerator.generateTemplate(
            forPath: "lib/my_app_web/controllers/user_controller.ex", 
            type: .controller
        )
        
        XCTAssertTrue(template.contains("defmodule MyAppWeb.UserController do"))
        XCTAssertTrue(template.contains("@moduledoc"))
        XCTAssertFalse(template.contains("use MyAppWeb"))
    }
}