//
//  NetworkMonitor.swift
//  TestTaskSfUI
//
//  Created by user246073 on 11/7/24.
//

import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global(qos: .background)

    @Published var isConnected: Bool = false

    init() {
        monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    func checkConnection() {
        // Perform network status update
        let path = monitor.currentPath
        isConnected = (path.status == .satisfied)
    }
}
