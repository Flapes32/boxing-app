import Foundation
import Combine

// Mock implementation of WatchConnectivityManager that doesn't rely on WatchConnectivity module
public class WatchConnectivityManager: NSObject, ObservableObject {
    public static let shared = WatchConnectivityManager()
    
    // Published properties for data exchange
    @Published public var receivedMessage: [String: Any] = [:]
    @Published public var isReachable = false
    @Published public var isActivated = false
    
    private override init() {
        super.init()
        print("WatchConnectivityManager initialized (mock version)")
    }
    
    // Mock methods for sending data
    public func sendMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        print("Mock: Would send message: \(message)")
        // Simulate successful sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            replyHandler?(["status": "success"])
        }
    }
    
    public func transferUserInfo(_ userInfo: [String: Any]) -> Any {
        print("Mock: Would transfer user info: \(userInfo)")
        return UUID()
    }
    
    public func transferFile(at url: URL, metadata: [String: Any]? = nil) -> Any {
        print("Mock: Would transfer file at: \(url)")
        return UUID()
    }
    
    // Mock activation method
    public func activate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isActivated = true
            print("Mock: WatchConnectivityManager activated")
        }
    }
    
    // Mock method to simulate receiving data
    public func simulateMessageReceived(_ message: [String: Any]) {
        DispatchQueue.main.async {
            self.receivedMessage = message
            print("Mock: Received message: \(message)")
        }
    }
}
