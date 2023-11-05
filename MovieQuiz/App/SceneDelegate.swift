import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard (scene as? UIWindowScene) != nil else { return }
        
        window = UIWindow.init(windowScene: scene as! UIWindowScene)
        
        
        let movieQuizController = MovieQuizViewController()
        let movieQuizPresenter = MovieQuizPresenter()
        
        movieQuizController.presenter = movieQuizPresenter
        movieQuizPresenter.viewController = movieQuizController
        
        
        window?.rootViewController = movieQuizController //movie-ios
        window?.makeKeyAndVisible()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
