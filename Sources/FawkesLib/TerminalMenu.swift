import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// An interactive terminal menu that supports keyboard navigation
public struct TerminalMenu {
    
    // MARK: - Types
    
    public enum SelectionResult: Equatable {
        case selected(index: Int)
        case cancelled
        
        public var selectedIndex: Int? {
            switch self {
            case .selected(let index):
                return index
            case .cancelled:
                return nil
            }
        }
    }
    
    // MARK: - Properties
    
    private let items: [String]
    private let prompt: String
    
    // MARK: - Initialization
    
    /// Initialize a terminal menu with the given items and prompt
    /// - Parameters:
    ///   - items: Array of menu items to display
    ///   - prompt: Text to display above the menu
    public init(items: [String], prompt: String = "Select an option:") {
        self.items = items
        self.prompt = prompt
    }
    
    // MARK: - Public Methods
    
    /// Display the menu and wait for user selection
    /// - Returns: The result of the selection (selected index or cancelled)
    public func show() -> SelectionResult {
        // Save current terminal state
        let originalTerminalSettings = saveTerminalSettings()
        defer {
            // Restore terminal state when function exits
            restoreTerminalSettings(originalTerminalSettings)
        }
        
        // Set terminal to raw mode
        setRawMode()
        
        // Display the menu
        var selectedIndex = 0
        var result: SelectionResult?
        
        while result == nil {
            // Clear screen and redraw menu
            clearScreen()
            printMenu(selectedIndex: selectedIndex)
            
            // Read a key
            if let key = readKey() {
                switch key {
                case .up, .k:
                    selectedIndex = (selectedIndex > 0) ? selectedIndex - 1 : items.count - 1
                case .down, .j:
                    selectedIndex = (selectedIndex < items.count - 1) ? selectedIndex + 1 : 0
                case .enter, .space:
                    result = .selected(index: selectedIndex)
                case .escape:
                    result = .cancelled
                case .number(let n) where n > 0 && n <= items.count:
                    result = .selected(index: n - 1)
                default:
                    break
                }
            }
        }
        
        // Print an empty line after selection
        print("")
        
        return result!
    }
    
    // MARK: - Private Methods
    
    private func printMenu(selectedIndex: Int) {
        print("\u{001B}[?25l") // Hide cursor
        print(prompt)
        print("")
        
        for (index, item) in items.enumerated() {
            if index == selectedIndex {
                print("\u{001B}[7m → \(item)\u{001B}[0m") // Highlight selected item
            } else {
                print("   \(item)")
            }
        }
        
        print("")
        print("Navigate: ↑/↓ or j/k | Select: Enter/Space | Cancel: Esc | Shortcut: 1-9")
    }
    
    private func clearScreen() {
        print("\u{001B}[2J") // Clear screen
        print("\u{001B}[H")  // Move cursor to top-left
    }
    
    // MARK: - Terminal Handling
    
    private enum Key {
        case up, down, left, right
        case enter, space, escape
        case k, j
        case number(Int)
        case other(UInt8)
    }
    
    private func readKey() -> Key? {
        var buffer = [UInt8](repeating: 0, count: 3)
        let bytesRead = readInputBytes(&buffer, count: 3)
        
        if bytesRead > 0 {
            switch buffer[0] {
            case 27: // ESC sequence
                if bytesRead >= 3 && buffer[1] == 91 { // ESC [ sequence
                    switch buffer[2] {
                    case 65: return .up
                    case 66: return .down
                    case 67: return .right
                    case 68: return .left
                    default: return .other(buffer[2])
                    }
                }
                return .escape
            case 10, 13: return .enter
            case 32: return .space
            case 106: return .j
            case 107: return .k
            case 49...57: return .number(Int(buffer[0] - 48)) // 1-9
            default: return .other(buffer[0])
            }
        }
        
        return nil
    }
    
    private func saveTerminalSettings() -> termios {
        var term = termios()
        tcgetattr(STDIN_FILENO, &term)
        return term
    }
    
    private func restoreTerminalSettings(_ settings: termios) {
        var settings = settings
        tcsetattr(STDIN_FILENO, TCSANOW, &settings)
        print("\u{001B}[?25h") // Show cursor
    }
    
    private func setRawMode() {
        var raw = termios()
        tcgetattr(STDIN_FILENO, &raw)
        
        #if canImport(Darwin)
        raw.c_lflag &= ~(UInt(ECHO | ICANON))
        #elseif canImport(Glibc)
        raw.c_lflag &= ~(UInt32(ECHO | ICANON))
        #endif
        
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
    }
    
    private func readInputBytes(_ buffer: UnsafeMutablePointer<UInt8>, count: Int) -> Int {
        return read(STDIN_FILENO, buffer, count)
    }
}