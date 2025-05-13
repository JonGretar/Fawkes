import XCTest
@testable import FawkesLib

final class PathTransformerTests: XCTestCase {
    
    func testToSnakeCase() {
        XCTAssertEqual(PathTransformer.toSnakeCase("UserController"), "user_controller")
        XCTAssertEqual(PathTransformer.toSnakeCase("user"), "user")
        XCTAssertEqual(PathTransformer.toSnakeCase("MyApp"), "my_app")
        XCTAssertEqual(PathTransformer.toSnakeCase("APIRequest"), "apirequest") // Special handling needed for acronyms
        XCTAssertEqual(PathTransformer.toSnakeCase(""), "")
    }
    
    func testToCamelCase() {
        XCTAssertEqual(PathTransformer.toCamelCase("user_controller"), "userController")
        XCTAssertEqual(PathTransformer.toCamelCase("user"), "user")
        XCTAssertEqual(PathTransformer.toCamelCase("my_app"), "myApp")
        XCTAssertEqual(PathTransformer.toCamelCase("my_app_web"), "myAppWeb")
        XCTAssertEqual(PathTransformer.toCamelCase(""), "")
    }
    
    func testToPascalCase() {
        XCTAssertEqual(PathTransformer.toPascalCase("user_controller"), "UserController")
        XCTAssertEqual(PathTransformer.toPascalCase("user"), "User")
        XCTAssertEqual(PathTransformer.toPascalCase("my_app"), "MyApp")
        XCTAssertEqual(PathTransformer.toPascalCase("my_app_web"), "MyAppWeb")
        XCTAssertEqual(PathTransformer.toPascalCase(""), "")
    }
    
    func testToElixirModule() {
        XCTAssertEqual(PathTransformer.toElixirModule("user_controller"), "UserController")
        XCTAssertEqual(PathTransformer.toElixirModule("my_app_web"), "MyAppWeb")
    }
    
    func testPathToModuleName() {
        XCTAssertEqual(
            PathTransformer.pathToModuleName("lib/my_app/user.ex"), 
            "MyApp.User"
        )
        
        XCTAssertEqual(
            PathTransformer.pathToModuleName("lib/my_app_web/controllers/user_controller.ex"),
            "MyAppWeb.UserController"
        )
        
        XCTAssertEqual(
            PathTransformer.pathToModuleName("test/my_app/user_test.exs"),
            "MyApp.UserTest"
        )
        
        XCTAssertEqual(
            PathTransformer.pathToModuleName("lib/my_app_web/live/user_live.ex"),
            "MyAppWeb.UserLive"
        )
        
        XCTAssertEqual(
            PathTransformer.pathToModuleName("lib/my_app/accounts/user.ex"),
            "MyApp.Accounts.User"
        )
    }
    
    func testModuleNameToPath() {
        XCTAssertEqual(
            PathTransformer.moduleNameToPath("MyApp.User"),
            "lib/my_app/user.ex"
        )
        
        XCTAssertEqual(
            PathTransformer.moduleNameToPath("MyAppWeb.UserController"),
            "lib/my_app_web/controllers/user_controller.ex"
        )
        
        XCTAssertEqual(
            PathTransformer.moduleNameToPath("MyApp.User", rootDir: "test", fileExtension: "exs"),
            "test/my_app/user.exs"
        )
        
        XCTAssertEqual(
            PathTransformer.moduleNameToPath("MyAppWeb.UserLive"),
            "lib/my_app_web/live/user_live.ex"
        )
        
        XCTAssertEqual(
            PathTransformer.moduleNameToPath("MyApp.Accounts.User"),
            "lib/my_app/accounts/user.ex"
        )
    }
}