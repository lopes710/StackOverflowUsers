//
//  UserTableViewCell.swift
//  StackOverflowUsers
//
//  Created by Duarte Santos Lopes on 20/05/2026.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    private enum Constants {
        static let avatarSize: CGFloat = 40
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 10
        static let spacing: CGFloat = 12
        static let followButtonWidth: CGFloat = 90
        static let placeholderImageName = "person.circle"
        static let followingText = "Following"
        static let followText = "Follow"
        static let unfollowText = "Unfollow"
        static let reputationPrefix = "Reputation:"
        static let emptyFollowingText = " "
    }

    var onFollowButtonTapped: (() -> Void)?

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: Constants.placeholderImageName)
        imageView.tintColor = .secondaryLabel
        imageView.backgroundColor = .systemGray5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.avatarSize / 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let reputationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let followIndicatorLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.followingText
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            reputationLabel,
            followIndicatorLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            avatarImageView,
            labelsStackView,
            followButton
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Constants.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarImageView.image = UIImage(systemName: Constants.placeholderImageName)
        nameLabel.text = nil
        reputationLabel.text = nil
        followIndicatorLabel.text = Constants.emptyFollowingText
        followButton.setTitle(nil, for: .normal)
        onFollowButtonTapped = nil
    }

    // MARK: - Public

    func configure(with user: User, imageLoader: ImageLoader) {
        nameLabel.text = user.displayName
        reputationLabel.text = "\(Constants.reputationPrefix) \(user.reputation)"
        followIndicatorLabel.text = user.isFollowed ? Constants.followingText : Constants.emptyFollowingText
        followButton.setTitle(user.isFollowed ? Constants.unfollowText : Constants.followText, for: .normal)

        loadImage(from: user.profileImageURL, imageLoader: imageLoader)
    }

    // MARK: - Private

    private func setupView() {
        selectionStyle = .none
        
        contentView.addSubview(horizontalStackView)
        
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            horizontalStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),
            horizontalStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.verticalPadding
            ),
            horizontalStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.verticalPadding
            ),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            
            followButton.widthAnchor.constraint(equalToConstant: Constants.followButtonWidth)
        ])
    }
    
    private func loadImage(from url: URL?, imageLoader: ImageLoader) {
        Task { [weak self] in
            let image = await imageLoader.loadImage(from: url)
            
            await MainActor.run {
                guard let image else {
                    return
                }
                
                self?.avatarImageView.image = image
            }
        }
    }

    @objc
    private func didTapFollowButton() {
        onFollowButtonTapped?()
    }
}
