import XCTest
@testable import FawkesLib

final class AlternateTests: XCTestCase {
    
    // Test fixtures
    private let converter = AlternatePathConverter()
    
    // Test error handling
    func testErrorHandling() {
        // Test invalid path with no filename
        XCTAssertThrowsError(try converter.convertPath(inputPath: "lib/sneffels/", altType: .test)) { error in
            guard let conversionError = error as? ConversionError else {
                XCTFail("Expected ConversionError")
                return
            }
        
            if case .invalidPath(let path) = conversionError {
                XCTAssertEqual(path, "lib/sneffels/")
            } else {
                XCTFail("Expected invalidPath error")
            }
        }
    }
    
    // MARK: - Test Conversions
    
    func testTestConversions() throws {
        // Implementation file to test file
        let result1 = try converter.convertPath(inputPath: "lib/sneffels/waypoints.ex", altType: .test)
        XCTAssertEqual(result1.path, "test/sneffels/waypoints_test.exs")
        XCTAssertEqual(result1.type, .test)
        
        // Test file to implementation file
        let result2 = try converter.convertPath(inputPath: "test/sneffels/waypoints_test.exs", altType: .test)
        XCTAssertEqual(result2.path, "lib/sneffels/waypoints.ex")
        XCTAssertEqual(result2.type, .test)
        
        // Web controller to controller test
        let result3 = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .test)
        XCTAssertEqual(result3.path, "test/sneffels_web/controllers/page_controller_test.exs")
        XCTAssertEqual(result3.type, .test)
        
        // Handle relative paths with "./" prefix
        let result4 = try converter.convertPath(inputPath: "./lib/sneffels/waypoints.ex", altType: .test)
        XCTAssertEqual(result4.path, "./test/sneffels/waypoints_test.exs")
        XCTAssertEqual(result4.type, .test)
    

    }
    
    func testControllerConversions() throws {
        // Module file to controller
        let result1 = try converter.convertPath(inputPath: "lib/sneffels/waypoints/sight.ex", altType: .controller)
        XCTAssertEqual(result1.path, "lib/sneffels/sneffels_web/controllers/waypoints/sight_controller.ex")
        XCTAssertEqual(result1.type, .controller)
        
        // LiveView to controller
        let result2 = try converter.convertPath(inputPath: "lib/sneffels_web/live/map_live.ex", altType: .controller)
        XCTAssertEqual(result2.path, "lib/sneffels_web/controllers/live/map_live_controller.ex")
        XCTAssertEqual(result2.type, .controller)
    }
    
    func testModelConversions() throws {
        // Controller to model
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .model)
        XCTAssertEqual(result.path, "lib/sneffels/page.ex")
        XCTAssertEqual(result.type, .model)
    }
    
    func testViewConversions() throws {
        // Controller to view
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .view)
        XCTAssertEqual(result.path, "lib/sneffels_web/views/page_view.ex")
        XCTAssertEqual(result.type, .view)
    }
    
    func testHtmlConversions() throws {
        // Controller to HTML
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .html)
        XCTAssertEqual(result.path, "lib/sneffels_web/controllers/page_html/index.html.heex")
        XCTAssertEqual(result.type, .html)
    }
    
    func testLiveViewConversions() throws {
        // Controller to LiveView
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .live)
        XCTAssertEqual(result.path, "lib/sneffels_web/live/page_live.ex")
        XCTAssertEqual(result.type, .live)
    }
    
    func testComponentConversions() throws {
        // Controller to Component
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .component)
        XCTAssertEqual(result.path, "lib/sneffels_web/components/page.ex")
        XCTAssertEqual(result.type, .component)
    }
    
    func testLiveComponentConversions() throws {
        // Controller to LiveComponent
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .liveComponent)
        XCTAssertEqual(result.path, "lib/sneffels_web/live/page_component.ex")
        XCTAssertEqual(result.type, .liveComponent)
    }
    
    func testChannelConversions() throws {
        // Controller to Channel
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .channel)
        XCTAssertEqual(result.path, "lib/sneffels_web/channels/page_channel.ex")
        XCTAssertEqual(result.type, .channel)
    }
    
    func testJsonConversions() throws {
        // Controller to JSON
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .json)
        XCTAssertEqual(result.path, "lib/sneffels_web/controllers/page_json.ex")
        XCTAssertEqual(result.type, .json)
    }
    
    func testTaskConversions() throws {
        // Regular file to Mix Task
        let result = try converter.convertPath(inputPath: "lib/sneffels/utils/data_importer.ex", altType: .task)
        XCTAssertEqual(result.path, "lib/mix/tasks/sneffels/utils/data_importer.ex")
        XCTAssertEqual(result.type, .task)
    }
    
    func testFeatureConversions() throws {
        // Controller to Feature test
        let result = try converter.convertPath(inputPath: "lib/sneffels_web/controllers/page_controller.ex", altType: .feature)
        XCTAssertEqual(result.path, "test/features/sneffels_web/controllers/page_controller_test.exs")
        XCTAssertEqual(result.type, .feature)
    }
}