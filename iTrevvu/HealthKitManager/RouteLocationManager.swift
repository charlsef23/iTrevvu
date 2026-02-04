import Foundation
import Combine
import CoreLocation

@MainActor
final class RouteLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var isEnabled: Bool = false
    @Published var path: [CLLocationCoordinate2D] = []
    @Published var distanceMeters: Double = 0
    @Published var currentSpeed: Double = 0 // m/s

    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 3
    }

    func request() {
        manager.requestWhenInUseAuthorization()
    }

    func start() {
        path.removeAll()
        distanceMeters = 0
        currentSpeed = 0
        lastLocation = nil
        manager.startUpdatingLocation()
        isEnabled = true
    }

    func stop() {
        manager.stopUpdatingLocation()
        isEnabled = false
    }

    // CLLocationManagerDelegate
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        Task { @MainActor in
            self.currentSpeed = max(loc.speed, 0)

            self.path.append(loc.coordinate)

            if let last = self.lastLocation {
                self.distanceMeters += loc.distance(from: last)
            }
            self.lastLocation = loc
        }
    }
}
