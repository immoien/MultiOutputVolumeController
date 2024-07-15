import Combine

class DeviceMonitor: ObservableObject {
    @Published var devices: [AudioDevice] = []
    
    init() {
        devices = AudioManager.shared.getDevices()
    }
}
