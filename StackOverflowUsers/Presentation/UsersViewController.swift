//
//  UsersViewController.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 18/05/2026.
//

import UIKit

private enum Constants {
    static let userCellName = "UserTableViewCell"
    static let title = "StackOverflow Users"
    static let cellHeight = 82.0
}

final class UsersViewController: UIViewController {
    private let viewModel: UsersViewModel
    private let imageLoader: ImageLoader
    private var didLoadUsers = false
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: Constants.userCellName)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    
    init(
        viewModel: UsersViewModel = UsersViewModel(),
        imageLoader: ImageLoader = ImageLoader()
    ) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = UsersViewModel()
        self.imageLoader = ImageLoader()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        bindViewModel()
        
        Task {
            await viewModel.loadUsers()
        }
    }
}

// MARK: - Private

private extension UsersViewController {
    func setupView() {
        title = Constants.title
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.rowHeight = Constants.cellHeight
    }
    
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            Task { @MainActor in
                self?.render(state)
            }
        }
    }
    
    func render(_ state: UsersViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true
            
        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            emptyLabel.isHidden = true
            didLoadUsers = false
            
        case .loaded:
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = true
            tableView.isHidden = false
            
            if !didLoadUsers {
                didLoadUsers = true
                tableView.reloadData()
            }
            
        case .empty(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            emptyLabel.text = message
            emptyLabel.isHidden = false
        }
    }
}

// MARK: - UITableViewDataSource

extension UsersViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.users.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.userCellName,
            for: indexPath
        ) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = viewModel.users[indexPath.row]
        
        cell.configure(with: user, imageLoader: imageLoader)
        cell.onFollowButtonTapped = { [weak self, weak cell] in
            guard
                let self,
                let cell,
                let indexPath = tableView.indexPath(for: cell)
            else {
                return
            }
            
            let user = self.viewModel.users[indexPath.row]
            self.viewModel.toggleFollow(userID: user.id)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
}
