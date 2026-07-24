import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

//        let rootViewController = WeatherViewController()
//        window.rootViewController = rootViewController
        window.rootViewController = WeatherViewController()
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Scene released
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // App became active
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // App going inactive
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Coming back to foreground
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save state if needed
    }
}
