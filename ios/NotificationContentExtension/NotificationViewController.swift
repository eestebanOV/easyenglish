import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.07, green: 0.09, blue: 0.15, alpha: 1.0) // #121826 Dark theme
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(red: 0.25, green: 0.40, blue: 0.95, alpha: 0.35).cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let headerBadgeContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.25, green: 0.40, blue: 0.95, alpha: 0.20)
        view.layer.cornerRadius = 8
        return view
    }()

    private let pinIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 0.45, green: 0.65, blue: 1.0, alpha: 1.0)
        if #available(iOS 13.0, *) {
            iv.image = UIImage(systemName: "pin.fill")
        }
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(white: 0.70, alpha: 1.0)
        label.numberOfLines = 1
        return label
    }()

    private let exampleSectionHeader: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "EJEMPLO DE USO"
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.textColor = UIColor(red: 0.45, green: 0.65, blue: 1.0, alpha: 1.0)
        label.letterSpacing = 1.2
        return label
    }()

    private let exampleCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.06)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(white: 1.0, alpha: 0.10).cgColor
        return view
    }()

    private let exampleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 19, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let grammarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.55, green: 0.20, blue: 0.85, alpha: 0.15)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor(red: 0.65, green: 0.35, blue: 0.95, alpha: 0.40).cgColor
        view.isHidden = true
        return view
    }()

    private let grammarHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "📐 FÓRMULA GRAMATICAL"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(red: 0.80, green: 0.60, blue: 1.0, alpha: 1.0)
        label.letterSpacing = 1.1
        return label
    }()

    private let grammarFormulaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private var grammarHeightConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear
        view.addSubview(containerView)

        containerView.addSubview(headerBadgeContainer)
        headerBadgeContainer.addSubview(pinIconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(exampleSectionHeader)
        containerView.addSubview(exampleCardView)
        exampleCardView.addSubview(exampleLabel)
        containerView.addSubview(grammarContainerView)
        grammarContainerView.addSubview(grammarHeaderLabel)
        grammarContainerView.addSubview(grammarFormulaLabel)

        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),

            // Header badge
            headerBadgeContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            headerBadgeContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headerBadgeContainer.widthAnchor.constraint(equalToConstant: 32),
            headerBadgeContainer.heightAnchor.constraint(equalToConstant: 32),

            pinIconImageView.centerXAnchor.constraint(equalTo: headerBadgeContainer.centerXAnchor),
            pinIconImageView.centerYAnchor.constraint(equalTo: headerBadgeContainer.centerYAnchor),
            pinIconImageView.widthAnchor.constraint(equalToConstant: 16),
            pinIconImageView.heightAnchor.constraint(equalToConstant: 16),

            // Title & Subtitle
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: headerBadgeContainer.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            // Example Section Header
            exampleSectionHeader.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            exampleSectionHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            exampleSectionHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Example Card View
            exampleCardView.topAnchor.constraint(equalTo: exampleSectionHeader.bottomAnchor, constant: 6),
            exampleCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            exampleCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // Example Label inside card
            exampleLabel.topAnchor.constraint(equalTo: exampleCardView.topAnchor, constant: 14),
            exampleLabel.leadingAnchor.constraint(equalTo: exampleCardView.leadingAnchor, constant: 14),
            exampleLabel.trailingAnchor.constraint(equalTo: exampleCardView.trailingAnchor, constant: -14),
            exampleLabel.bottomAnchor.constraint(equalTo: exampleCardView.bottomAnchor, constant: -14),

            // Grammar Container
            grammarContainerView.topAnchor.constraint(equalTo: exampleCardView.bottomAnchor, constant: 12),
            grammarContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            grammarContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            grammarContainerView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16),

            // Grammar labels
            grammarHeaderLabel.topAnchor.constraint(equalTo: grammarContainerView.topAnchor, constant: 8),
            grammarHeaderLabel.leadingAnchor.constraint(equalTo: grammarContainerView.leadingAnchor, constant: 10),
            grammarHeaderLabel.trailingAnchor.constraint(equalTo: grammarContainerView.trailingAnchor, constant: -10),

            grammarFormulaLabel.topAnchor.constraint(equalTo: grammarHeaderLabel.bottomAnchor, constant: 4),
            grammarFormulaLabel.leadingAnchor.constraint(equalTo: grammarContainerView.leadingAnchor, constant: 10),
            grammarFormulaLabel.trailingAnchor.constraint(equalTo: grammarContainerView.trailingAnchor, constant: -10),
            grammarFormulaLabel.bottomAnchor.constraint(equalTo: grammarContainerView.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - UNNotificationContentExtension
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        let userInfo = content.userInfo

        var wordEn = content.title
        var wordEs = ""
        var exampleText = content.body
        var grammarFormula: String? = nil

        // Attempt to parse structured JSON payload
        if let payloadString = userInfo["payload"] as? String,
           let data = payloadString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

            if let wEn = json["wordEn"] as? String, !wEn.isEmpty {
                wordEn = wEn
            }
            if let wEs = json["wordEs"] as? String, !wEs.isEmpty {
                wordEs = wEs
            }
            if let ex = json["example"] as? String, !ex.isEmpty {
                exampleText = ex
            }
            if let formula = json["grammarFormula"] as? String, !formula.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                grammarFormula = formula
            }
        } else {
            // Fallback parsing if JSON wasn't present
            if let openParen = wordEn.firstIndex(of: "("),
               let closeParen = wordEn.firstIndex(of: ")") {
                let start = wordEn.index(after: openParen)
                wordEs = String(wordEn[start..<closeParen])
                wordEn = String(wordEn[..<openParen]).trimmingCharacters(in: .whitespaces)
            }
        }

        titleLabel.text = wordEn
        subtitleLabel.text = wordEs.isEmpty ? "EasyEnglish" : wordEs

        // Format example with comfortable line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.paragraphSpacing = 4.0
        let attributedExample = NSAttributedString(
            string: "“\(exampleText)”",
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )
        exampleLabel.attributedText = attributedExample

        // Grammar formula conditional visibility
        if let formula = grammarFormula, !formula.isEmpty {
            grammarFormulaLabel.text = formula
            grammarContainerView.isHidden = false
        } else {
            grammarContainerView.isHidden = true
        }

        // Calculate and set preferred content size for smooth expansion
        view.layoutIfNeeded()
        let targetSize = view.systemLayoutSizeFitting(
            CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: max(targetSize.height, 220))
    }
}

// MARK: - Helper Extension
private extension UILabel {
    var letterSpacing: CGFloat {
        get { return 0 }
        set {
            guard let text = self.text else { return }
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(.kern, value: newValue, range: NSRange(location: 0, length: text.count))
            self.attributedText = attributedString
        }
    }
}
