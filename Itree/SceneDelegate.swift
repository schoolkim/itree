//
//  SceneDelegate.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/05/17.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var dataSource = CoreDataStore.shared
    static var hour = -1
    static var minute = -1
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "dd일 HH시 mm분"
        return formatter
    }()
    var notificationDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분 ss초"
        return formatter
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                guard let self = self else { return }
                if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                    var date = DateComponents()
                    self.dataSource.fetchTodo().forEach { element in
                        guard let todoAt = element.todoAt,
                              let uuid = element.uuid?.uuidString else { return }
                        
                        let nContent = UNMutableNotificationContent()
                        nContent.badge = 1
                        nContent.title = "Itree"
                        nContent.subtitle = "\(self.dateFormatter.string(from: todoAt))에 해야할 일이 있습니다!"
                        nContent.sound = UNNotificationSound.default
                        nContent.userInfo = ["name" : "kim"]

                        date.hour = todoAt.hour
                        date.minute = todoAt.minute
                        if SceneDelegate.hour == todoAt.hour && SceneDelegate.minute == todoAt.minute {
                            return
                        }
                        SceneDelegate.hour = todoAt.hour
                        SceneDelegate.minute = todoAt.minute
                        

                        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)

                        let request = UNNotificationRequest(identifier: uuid, content: nContent, trigger: trigger)

                        UNUserNotificationCenter.current().add(request) { e in
                            
                        }
                                        
                    }


                } else {
                    NSLog("User not agree")
                }
            }
        } else {
            NSLog("This ios version can't action")
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

