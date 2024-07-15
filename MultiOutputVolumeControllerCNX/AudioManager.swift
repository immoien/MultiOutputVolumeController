import Foundation
import AVFoundation
import CoreAudio

class AudioManager {
    static let shared = AudioManager()
    
    private init() {}
    
    func getDevices() -> [AudioDevice] {
        var devices: [AudioDevice] = []
        
        var dataSize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize)
        
        let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
        
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize, &deviceIDs)
        
        for deviceID in deviceIDs {
            var name: CFString = "" as CFString
            var nameSize = UInt32(MemoryLayout<CFString>.size)
            var nameAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyDeviceNameCFString,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )
            
            AudioObjectGetPropertyData(deviceID, &nameAddress, 0, nil, &nameSize, &name)
            
            devices.append(AudioDevice(id: deviceID, name: name as String, volume: getVolume(for: deviceID)))
        }
        
        return devices
    }
    
    func getVolume(for device: AudioDeviceID) -> Float {
        var volume: Float32 = 0
        var volumeSize = UInt32(MemoryLayout<Float32>.size)
        var volumeAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectGetPropertyData(device, &volumeAddress, 0, nil, &volumeSize, &volume)
        
        return volume
    }
    
    func setVolume(for device: AudioDevice, volume: Float) {
        var volume = volume
        let size = UInt32(MemoryLayout<Float32>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectSetPropertyData(device.id, &address, 0, nil, size, &volume)
    }
    
    func setMasterVolume(_ volume: Float) {
        let devices = getDevices()
        for device in devices {
            setVolume(for: device, volume: volume)
        }
    }
    
    func setup() {
        // Initial setup if required
    }
}

struct AudioDevice: Identifiable {
    let id: AudioObjectID
    let name: String
    var volume: Float
}
