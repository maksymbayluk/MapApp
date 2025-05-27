//
//  SideMenuContainerViewController.swift
//  MapApp
//
//  Created by Максим Байлюк on 27.05.2025.
//
import UIKit


class SideMenuContainerViewController: UIViewController {

    private let sideMenuWidth: CGFloat = UIScreen.main.bounds.width * 0.7
    private var isMenuOpen = false
    private let sideMenuVC: SideMenuViewController
    private let mainMapViewController: MainMapViewController
    private var currentContentVC: UIViewController!
    weak var delegate: SideMenuContainerDelegate?
    private let dimmedView = UIView()

    init(mainMapViewController: MainMapViewController, sideMenuViewController: SideMenuViewController) {
        self.mainMapViewController = mainMapViewController
        currentContentVC = mainMapViewController
        sideMenuVC = sideMenuViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChildVCs()
        setupGestures(for: mainMapViewController)
        setupDimmedView(on: mainMapViewController)
    }

    func setupUI() {
        title = "Map"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(toggleMenu)
        )
    }

    private func setupChildVCs() {
        addChild(sideMenuVC)
        sideMenuVC.view.frame = CGRect(x: -sideMenuWidth, y: 0, width: sideMenuWidth, height: view.frame.height)
        view.addSubview(sideMenuVC.view)
        sideMenuVC.didMove(toParent: self)

        addChild(mainMapViewController)
        mainMapViewController.view.frame = view.bounds
        view.addSubview(mainMapViewController.view)
        mainMapViewController.didMove(toParent: self)

        if let mapVM = mainMapViewController.viewModel {
            mapVM.didTapMenu = { [weak self] in
                self?.toggleMenu()
            }
        }

        sideMenuVC.viewModel.onOptionSelected = { [weak self] option in
            self?.handleMenuOption(option)
        }
    }

    func setContentViewController(_ newVC: UIViewController) {
        if let current = currentContentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        addChild(newVC)
        newVC.view.frame = view.bounds

        view.insertSubview(newVC.view, belowSubview: sideMenuVC.view)

        newVC.didMove(toParent: self)
        currentContentVC = newVC
        title = newVC.title
        setupGestures(for: newVC)

        dimmedView.removeFromSuperview()
        dimmedView.frame = newVC.view.bounds
        newVC.view.addSubview(dimmedView)
    }

    private func setupDimmedView(on vc: UIViewController) {
        dimmedView.frame = vc.view.bounds
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedView.alpha = 0
        mainMapViewController.view.addSubview(dimmedView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        dimmedView.addGestureRecognizer(tap)
    }

    private func setupGestures(for vc: UIViewController) {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeRight.direction = .right
        vc.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeLeft.direction = .left
        vc.view.addGestureRecognizer(swipeLeft)
    }

    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            if !isMenuOpen {
                toggleMenu()
            }
        case .left:
            if isMenuOpen {
                toggleMenu()
            }
        default:
            break
        }
    }

    @objc private func toggleMenu() {
        isMenuOpen.toggle()

        let menuX = isMenuOpen ? 0 : -sideMenuWidth
        let mainX = isMenuOpen ? sideMenuWidth : 0
        let dimmedAlpha: CGFloat = isMenuOpen ? 1 : 0

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.sideMenuVC.view.frame.origin.x = menuX
            self.mainMapViewController.view.frame.origin.x = mainX
            self.dimmedView.alpha = dimmedAlpha
        })
    }

    private func handleMenuOption(_ option: SideMenuOption) {
        toggleMenu()
        delegate?.didSelectMenuOption(option)
    }
}
