//
//  CoreDataManager.swift
//  MyFitnessGoals
//
//  Created by Bach Nghiem on 19/01/2025.
//

import Foundation
import CoreData
import CoreLocation

enum DataType {
    case normal, preview
}

class CoreDataManager: ObservableObject {
    var persistenceController: PersistenceController
    
    static let shared = CoreDataManager(type: .normal)
    static let preview = CoreDataManager(type: .preview)
    
    @Published var workouts: [WorkoutEntity] = []
    @Published var distances: [DistanceEntity] = []
    @Published var speeds: [SpeedEntity] = []
    @Published var calories: [CalorieEntity] = []
    @Published var steps: [StepEntity] = []
    @Published var filteredWorkouts: [WorkoutEntity] = []

    init(type: DataType) {
        switch type {
        case .normal:
            persistenceController = PersistenceController()
        case .preview:
            persistenceController = PersistenceController()
//            mockData(persistenceController: persistenceController)
        }
        fetchWorkouts()
        fetchDistance()
        fetchSpeed()
        fetchCalories()
        fetchSteps()
    }
}

extension CoreDataManager {
    func fetchWorkouts() {
        let request = NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(WorkoutEntity.date), ascending: false)]
        do {
            workouts = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func fetchDistance() {
        let request = NSFetchRequest<DistanceEntity>(entityName: "DistanceEntity")
        do {
            distances = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func fetchSpeed() {
        let request = NSFetchRequest<SpeedEntity>(entityName: "SpeedEntity")
        do {
            speeds = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func fetchSteps() {
        let request = NSFetchRequest<StepEntity>(entityName: "StepEntity")
        do {
            steps = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func fetchCalories() {
        let request = NSFetchRequest<CalorieEntity>(entityName: "CalorieEntity")
        do {
            calories = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
    }
}

// MARK: Fetch requests returning objects for specific Workout
extension CoreDataManager {
    internal func getWorkout(withId worKoutId: UUID) -> [WorkoutEntity] {
        let request = NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
        request.predicate = NSPredicate(
            format: "uuid == %@", worKoutId as NSUUID)
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
        return [WorkoutEntity]()
    }

    internal func getDistance(for worKoutId: UUID) -> [DistanceEntity] {
        let request = NSFetchRequest<DistanceEntity>(entityName: "DistanceEntity")
        request.predicate = NSPredicate(
            format: "id == %@", worKoutId as NSUUID)
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
        return [DistanceEntity]()
    }

    internal func getSpeed(for worKoutId: UUID) -> [SpeedEntity] {
        let request = NSFetchRequest<SpeedEntity>(entityName: "SpeedEntity")
        request.predicate = NSPredicate(
            format: "id == %@", worKoutId as NSUUID)
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
        return [SpeedEntity]()
    }

    internal func getSteps(for worKoutId: UUID) -> [StepEntity] {
        let request = NSFetchRequest<StepEntity>(entityName: "StepEntity")
        request.predicate = NSPredicate(
            format: "id == %@", worKoutId as NSUUID)
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
        return [StepEntity]()
    }

    internal func getCalories(for worKoutId: UUID) -> [CalorieEntity] {
        let request = NSFetchRequest<CalorieEntity>(entityName: "CalorieEntity")
        request.predicate = NSPredicate(
            format: "id == %@", worKoutId as NSUUID)
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
        return [CalorieEntity]()
    }
}

// MARK: Fetch requests for filtering Workouts
extension CoreDataManager {
    func fetchWorkouts(request: NSFetchRequest<WorkoutEntity>) -> [WorkoutEntity] {
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print(error)
        }
        return []
    }

    func filterWorkouts(predicate: FilteredType) {
        let request = NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(WorkoutEntity.date), ascending: false)]
        switch predicate {
        case .running:
            request.predicate = NSPredicate(format: "type == %i",  WorkoutType.running.rawValue)
//            request.predicate = NSPredicate(format: "%K == %i", #keyPath(WorkoutEntity.type), WorkoutType.running.rawValue)
            filteredWorkouts = fetchWorkouts(request: request)
        case .walking:
            request.predicate = NSPredicate(format: "type == %i",  WorkoutType.walking.rawValue)
            filteredWorkouts = fetchWorkouts(request: request)
        case .cycling:
            request.predicate = NSPredicate(format: "type == %i", WorkoutType.cycling.rawValue)
            filteredWorkouts = fetchWorkouts(request: request)
        case .all:
            filteredWorkouts = fetchWorkouts(request: request)
        }
    }
}

extension CoreDataManager {
    func delete(_ object: NSManagedObject?) {
        if let object {
            persistenceController.container.viewContext.delete(object)
            save()
        }
    }

    func save() {
        if persistenceController.container.viewContext.hasChanges {
            do {
                try persistenceController.container.viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        fetchWorkouts()
        fetchDistance()
        fetchSpeed()
        fetchCalories()
        fetchSteps()
    }

    func add(_ workout: Workout) {
        let newWorkout = WorkoutEntity(context: persistenceController.container.viewContext)
        newWorkout.uuid = workout.id
        newWorkout.date = workout.date
        newWorkout.type = workout.type?.rawValue ?? 0
        newWorkout.routeLatitudes = workout.route.map({ $0.map { $0.coordinate.latitude }})
        newWorkout.routeLongitudes = workout.route.map({ $0.map { $0.coordinate.longitude }})
        newWorkout.duration = workout.duration
        newWorkout.distances = workout.distances.map({ $0.map { $0.value }})
        newWorkout.speeds = workout.speeds.map({ $0.map { $0.value } })
        newWorkout.altitudes = workout.altitudes.map({ $0.map { $0.value }})
        save()
//        addBaseFitnessModels(to: workout)
    }
    
    func addMetrics(to workout: Workout) {
        if let newWorkout = getWorkout(withId: workout.id).first {
            addDistance(to: newWorkout, measure: workout.distance?.measure)
            addSpeed(to: newWorkout, measure: workout.speed?.measure)
            addCalories(to: newWorkout, count: workout.calories?.count)
            addSteps(to: newWorkout, count: workout.steps?.count)
        }
    }

    private func addBaseFitnessModels(to workout: Workout) {
        if let newWorkout = getWorkout(withId: workout.id).first {
            addDistance(to: newWorkout, measure: workout.distance?.measure)
            addSpeed(to: newWorkout, measure: workout.speed?.measure)
            addCalories(to: newWorkout, count: workout.calories?.count)
            addSteps(to: newWorkout, count: workout.steps?.count)
            save()
        }
    }

    private func addDistance(to workout: WorkoutEntity, measure: Measurement<UnitLength>?) {
        let distance = DistanceEntity(context: persistenceController.container.viewContext)
        distance.id = workout.uuid
        distance.workoutType = workout.type
        distance.date = workout.date
        distance.type = MeasureUnit.distance.rawValue
        distance.distance = measure?.value ?? 0
        distance.workout = workout
        workout.distance = distance
        save()
    }

    private func addSpeed(to workout: WorkoutEntity, measure: Measurement<UnitSpeed>?) {
        let speed = SpeedEntity(context: persistenceController.container.viewContext)
        speed.id = workout.uuid
        speed.workoutType = workout.type
        speed.date = workout.date
        speed.type = MeasureUnit.speed.rawValue
        speed.speed = measure?.value ?? 0
        speed.workout = workout
        workout.speed = speed
        save()
    }
    
    private func addCalories(to workout: WorkoutEntity, count: Int?) {
        let calories = CalorieEntity(context: persistenceController.container.viewContext)
        calories.id = workout.uuid
        calories.workoutType = workout.type
        calories.date = workout.date
        calories.type = MeasureUnit.calorie.rawValue
        calories.calorie = Int16(count ?? 0)
        calories.workout = workout
        workout.calories = calories
        save()
    }

    private func addSteps(to workout: WorkoutEntity, count: Int?) {
        let steps = StepEntity(context: persistenceController.container.viewContext)
        steps.id = workout.uuid
        steps.workoutType = workout.type
        steps.date = workout.date
        steps.type = MeasureUnit.step.rawValue
        steps.step = Int16(count ?? 0)
        steps.workout = workout
        workout.steps = steps
        save()
    }
}

// MARK: Methods for conversion
extension CoreDataManager {
    internal func workoutToNSManagedObject(_ workout: Workout) -> NSManagedObject {
        let request = getWorkout(withId: workout.id)
        return request.first ?? WorkoutEntity()
    }

    internal func BaseFitnessModelToNSManagedObject(_ measure: MeasureUnit, BaseFitnessModelId: UUID) -> NSManagedObject {
        switch measure {
        case .distance:
            let request = getDistance(for: BaseFitnessModelId)
            return request.first ?? DistanceEntity()
        case .speed:
            let request = getSpeed(for: BaseFitnessModelId)
            return request.first ?? SpeedEntity()
        case .step:
            let request = getSteps(for: BaseFitnessModelId)
            return request.first ?? StepEntity()
        case .calorie:
            let request = getCalories(for: BaseFitnessModelId)
            return request.first ?? CalorieEntity()
        case .heartRate:
            return NSManagedObject()
        }
    }

    internal func nSManagedObjectToWorkout(_ workout: WorkoutEntity) -> Workout {
        var route: [CLLocation] {
            var route: [CLLocation] = []
            zip(workout.routeLatitudes ?? [], workout.routeLongitudes ?? []).forEach({ route.append(CLLocation.init(latitude: $0, longitude: $1))})
            return route
        }
        let workout = Workout(
            id: workout.uuid ?? UUID(),
            date: workout.date,
            type: WorkoutType(rawValue: workout.type),
            route: route,
            duration: workout.duration,
            distance: workout.distance != nil ? mapToBaseFitness(workout.distance!) as? Distance : nil,
            speed: workout.speed != nil ? mapToBaseFitness(workout.speed!) as? Speed : nil,
            distances: workout.distances.map({ $0.map({ Measurement.init(value: $0, unit: .meters )})}),
            speeds: workout.speeds.map({ $0.map({ Measurement.init(value: $0, unit: .metersPerSecond )})}),
            altitudes: workout.altitudes.map({ $0.map({ Measurement.init(value: $0, unit: .meters )})}),
            steps: workout.steps != nil ? mapToBaseFitness(workout.steps!) as? Step : nil,
            calories: workout.calories != nil ? mapToBaseFitness(workout.calories!) as? Calorie : nil
        )
        return workout
    }

    internal func mapToBaseFitness(_ object: NSManagedObject) -> BaseFitnessModel? {
        switch object {
        case let distanceEntity as DistanceEntity:
            return Distance(
                id: distanceEntity.id ?? UUID(),
                workoutType: WorkoutType(rawValue: distanceEntity.workoutType),
                date: distanceEntity.date,
                measure: Measurement(value: distanceEntity.distance, unit: .meters)
            )
            
        case let speedEntity as SpeedEntity:
            return Speed(
                id: speedEntity.id ?? UUID(),
                workoutType: WorkoutType(rawValue: speedEntity.workoutType),
                date: speedEntity.date,
                measure: Measurement(value: speedEntity.speed, unit: .metersPerSecond)
            )
            
        case let stepEntity as StepEntity:
            return Step(
                id: stepEntity.id ?? UUID(),
                workoutType: WorkoutType(rawValue: stepEntity.workoutType),
                date: stepEntity.date,
                count: Int(stepEntity.step)
            )
            
        case let calorieEntity as CalorieEntity:
            return Calorie(
                id: calorieEntity.id ?? UUID() ,
                workoutType: WorkoutType(rawValue: calorieEntity.workoutType),
                date: calorieEntity.date,
                count: Int(calorieEntity.calorie)
            )
            
        default:
            return nil
        }
    }

}
