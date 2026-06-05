import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let repository = CryptoRepository()
        let mainViewModel = MainViewModel(repository: repository)
        let mainViewController = MainViewController(viewModel: mainViewModel, repository: repository)
        let navigationController = UINavigationController(rootViewController: mainViewController)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
