import SwiftUI
import CoreLocation
import HealthKit

class DistanceTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?
    
    @Published var distance: Double = 0.0
    private var lastLocation: CLLocation?
    private var startDate: Date?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        locationManager.requestAlwaysAuthorization()
    }
    
    func startTracking() {
        // Inicializace HealthKit
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType(.distanceWalkingRunning)
        ]
        
        let typesToRead: Set = [
            HKQuantityType(.distanceWalkingRunning)
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                self.startWorkout()
            }
        }
        
        locationManager.startUpdatingLocation()
        startDate = Date()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        workoutSession?.end()
        saveWorkout()
    }
    
    private func startWorkout() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date()) { success, error in
                // Spuštěno
            }
        } catch {
            print("Chyba při inicializaci workout session: \(error)")
        }
    }
    
    private func saveWorkout() {
        guard let startDate = startDate else { return }
        
        let workout = HKWorkout(
            activityType: .running,
            start: startDate,
            end: Date(),
            duration: Date().timeIntervalSince(startDate),
            totalEnergyBurned: nil,
            totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
            metadata: nil
        )
        
        healthStore.save(workout) { success, error in
            if success {
                print("Workout úspěšně uložen")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, newLocation.horizontalAccuracy >= 0 else { return }
        
        if let lastLocation = lastLocation {
            let delta = lastLocation.distance(from: newLocation)
            distance += delta
            
            // Vytvoření HKQuantitySample pro HealthKit
            let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: delta)
            let distanceSample = HKQuantitySample(
                type: distanceType,
                quantity: distanceQuantity,
                start: lastLocation.timestamp,
                end: newLocation.timestamp
            )
            
            workoutBuilder?.add([distanceSample], completion: { success, error in
                if let error = error {
                    print("Chyba při ukládání dat do HealthKit: \(error)")
                }
            })
        }
        lastLocation = newLocation
    }
}

struct DistanceView: View {
    @StateObject private var tracker = DistanceTracker()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Uběhnutá vzdálenost")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("\(String(format: "%.2f", tracker.distance / 1000)) km")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            tracker.startTracking()
        }
        .onDisappear {
            tracker.stopTracking()
        }
    }
} 