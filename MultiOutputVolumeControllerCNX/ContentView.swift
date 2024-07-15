import SwiftUI

struct ContentView: View {
    @State private var devices: [AudioDevice] = []
    @State private var masterVolume: Float = 1.0
    
    var body: some View {
        VStack {
            Text("Multi-Output Volume Controller")
                .font(.largeTitle)
                .padding()
            
            List(devices) { device in
                HStack {
                    Text(device.name)
                    Slider(value: Binding(
                        get: { device.volume },
                        set: { newValue in
                            AudioManager.shared.setVolume(for: device, volume: newValue)
                            updateDeviceVolume(device: device, volume: newValue)
                        }
                    ), in: 0...1)
                }
            }
            
            HStack {
                Text("Master Volume")
                Slider(value: $masterVolume, in: 0...1, onEditingChanged: { _ in
                    AudioManager.shared.setMasterVolume(masterVolume)
                })
            }
            .padding()
        }
        .padding()
        .onAppear {
            AudioManager.shared.setup()
            devices = AudioManager.shared.getDevices()
        }
    }
    
    private func updateDeviceVolume(device: AudioDevice, volume: Float) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index].volume = volume
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
