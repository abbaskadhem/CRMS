//
//  CategoryManagementViewController.swift
//  CRMS
//
//  Created by Macos on 24/12/2025.
//

//import UIKit
//
//class CategoryManagementViewController: UIViewController {
//
//    // MARK: - IBOutlets
//
//    @IBOutlet weak var searchTextField: UITextField!
//    @IBOutlet weak var editSearchButton: UIButton!
//    @IBOutlet weak var addCategoryButton: UIButton!
//    @IBOutlet weak var addSubCategoryButton: UIButton!
//    @IBOutlet weak var tableView: UITableView!
//    // MARK: - Properties
//    var categories: [Category] = []
//    var selectedCategory: Category?
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupTableView()
//        loadInitialCategories()
//    }
//
//    // MARK: - Setup
//    private func setupUI() {
//        title = "Category Management"
//
//        // Search field
//        searchTextField.placeholder = "Search"
//        searchTextField.borderStyle = .roundedRect
//        searchTextField.clearButtonMode = .whileEditing
//
//        // Buttons
//        addCategoryButton.setTitle("Add Category", for: .normal)
//        addSubCategoryButton.setTitle("Add Sub-Category", for: .normal)
//
//        addCategoryButton.backgroundColor = UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
//        addSubCategoryButton.backgroundColor = UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
//
//        addCategoryButton.layer.cornerRadius = 8
//        addSubCategoryButton.layer.cornerRadius = 8
//
//        addCategoryButton.setTitleColor(.white, for: .normal)
//        addSubCategoryButton.setTitleColor(.white, for: .normal)
//    }
//
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
//        tableView.register(SubCategoryCell.self, forCellReuseIdentifier: "SubCategoryCell")
//        tableView.separatorStyle = .none
//    }
//
//    private func loadInitialCategories() {
//        // البيانات الأولية - المستوى الأول
//        categories = [
//            Category(name: "IT", isExpanded: false, subCategories: []),
//            Category(name: "HVAC", isExpanded: false, subCategories: []),
//            Category(name: "Electrical", isExpanded: false, subCategories: []),
//            Category(name: "Security", isExpanded: false, subCategories: [])
//        ]
//        tableView.reloadData()
//    }
//    @IBAction func editButtonTapped(_ sender: Any) {
//        print("AeditCategory tapped")
//    }
//
//    @IBAction func addSubCategoryTapped(_ sender: Any) {
//        print("Add Sub-Category tapped")
//    }
//    @IBAction func addCategoryTapped(_ sender: Any) {
//        print("Add Category tapped")
//    }
//
//}
//
//// MARK: - UITableViewDelegate & DataSource
//extension CategoryManagementViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return categories.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let category = categories[section]
//        return category.isExpanded ? category.subCategories.count + 1 : 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let category = categories[indexPath.section]
//
//        // أول صف في كل section هو الـ Category الرئيسي
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
//            cell.configure(with: category.name, isExpanded: category.isExpanded)
//            return cell
//        } else {
//            // الصفوف التانية هي الـ SubCategories
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
//            let subCategory = category.subCategories[indexPath.row - 1]
//            cell.configure(with: subCategory)
//            return cell
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        // لو دوست على Category رئيسي
//        if indexPath.row == 0 {
//            categories[indexPath.section].isExpanded.toggle()
//
//            // تحميل الـ SubCategories بناءً على الـ Category المختار
//            if categories[indexPath.section].isExpanded {
//                loadSubCategories(for: indexPath.section)
//            }
//
//            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
//        }
//    }
//
//    private func loadSubCategories(for section: Int) {
//        let categoryName = categories[section].name
//
//        // تحميل الـ SubCategories بناءً على الـ Category
//        switch categoryName {
//        case "IT":
//            categories[section].subCategories = ["Software", "Hardware", "Network"]
//        case "HVAC":
//            categories[section].subCategories = ["Heating", "Ventilation", "Air Conditioning"]
//        case "Electrical":
//            categories[section].subCategories = ["Lights", "Outlets", "Switches", "Elevators", "Sliding Doors"]
//        case "Security":
//            categories[section].subCategories = ["Fingerprint Sensors", "ID Card Sensors", "CCTV"]
//        default:
//            categories[section].subCategories = []
//        }
//    }
//}
//
//// MARK: - Models
//struct Category {
//    let name: String
//    var isExpanded: Bool
//    var subCategories: [String]
//}
//
//// MARK: - Category Cell
//class CategoryCell: UITableViewCell {
//
//    private let containerView = UIView()
//    private let nameLabel = UILabel()
//    private let arrowImageView = UIImageView()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupCell() {
//        selectionStyle = .none
//        backgroundColor = .clear
//
//        // Container
//        containerView.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 0.85, alpha: 1.0)
//        containerView.layer.cornerRadius = 8
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(containerView)
//
//        // Label
//        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        nameLabel.textColor = .darkGray
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(nameLabel)
//
//        // Arrow
//        arrowImageView.tintColor = .darkGray
//        arrowImageView.contentMode = .scaleAspectFit
//        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(arrowImageView)
//
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
//            containerView.heightAnchor.constraint(equalToConstant: 50),
//
//            arrowImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
//            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
//            arrowImageView.heightAnchor.constraint(equalToConstant: 20),
//
//            nameLabel.leadingAnchor.constraint(equalTo: arrowImageView.trailingAnchor, constant: 8),
//            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
//        ])
//    }
//
//    func configure(with name: String, isExpanded: Bool) {
//        nameLabel.text = name
//
//        // السهم: لتحت لو مفتوح، لليمين لو مقفول
//        let arrowImage = isExpanded ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.right")
//        arrowImageView.image = arrowImage
//    }
//}
//
//// MARK: - SubCategory Cell
//class SubCategoryCell: UITableViewCell {
//
//    private let containerView = UIView()
//    private let nameLabel = UILabel()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupCell()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupCell() {
//        selectionStyle = .none
//        backgroundColor = .clear
//
//        // Container
//        containerView.backgroundColor = .white
//        containerView.layer.cornerRadius = 8
//        containerView.layer.borderWidth = 1
//        containerView.layer.borderColor = UIColor.lightGray.cgColor
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(containerView)
//
//        // Label
//        nameLabel.font = UIFont.systemFont(ofSize: 15)
//        nameLabel.textColor = .darkGray
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(nameLabel)
//
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
//            containerView.heightAnchor.constraint(equalToConstant: 44),
//
//            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
//            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
//        ])
//    }
//
//    func configure(with name: String) {
//        nameLabel.text = name
//    }
//}

import UIKit

class CategoryManagementViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var editSearchButton: UIButton!
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var addSubCategoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var categories: [Category] = []
    var selectedCategory: Category?
    var isEditMode: Bool = false // وضع التعديل
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadInitialCategories()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Category Management"
        
        
        // Search field
        searchTextField.placeholder = "Search"
        searchTextField.borderStyle = .roundedRect
        searchTextField.clearButtonMode = .whileEditing
        
        // Buttons
        addCategoryButton.setTitle("Add Category", for: .normal)
        addSubCategoryButton.setTitle("Add Sub-Category", for: .normal)
        
        addCategoryButton.backgroundColor = UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
        addSubCategoryButton.backgroundColor = UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
        
        addCategoryButton.layer.cornerRadius = 8
        addSubCategoryButton.layer.cornerRadius = 8
        
        addCategoryButton.setTitleColor(.white, for: .normal)
        addSubCategoryButton.setTitleColor(.white, for: .normal)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.register(SubCategoryCell.self, forCellReuseIdentifier: "SubCategoryCell")
        tableView.separatorStyle = .none
    }
    
    private func loadInitialCategories() {
        // البيانات الأولية - المستوى الأول
        categories = [
            Category(name: "IT", isExpanded: false, subCategories: []),
            Category(name: "HVAC", isExpanded: false, subCategories: []),
            Category(name: "Electrical", isExpanded: false, subCategories: []),
            Category(name: "Security", isExpanded: false, subCategories: [])
        ]
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func addCategoryTapped(_ sender: UIButton) {
        // كود إضافة Category جديد
        print("Add Category tapped")
        
        let confirmVC = storyboard?.instantiateViewController(
             withIdentifier: "AddCatogryViewController"
         ) as! AddCatogryViewController

         let confirmPopup = DraggablePopupViewController(
             contentVC: confirmVC,
             height: UIScreen.main.bounds.height * 0.75
         )

         present(confirmPopup, animated: false) {
             confirmPopup.presentPopup()
         }
        
    }
    
    @IBAction func addSubCategoryTapped(_ sender: UIButton) {
        // كود إضافة Sub-Category جديد
        
        let confirmVC = storyboard?.instantiateViewController(
             withIdentifier: "AddSubCatogryViewController"
         ) as! AddSubCatogryViewController

         let confirmPopup = DraggablePopupViewController(
             contentVC: confirmVC,
             height: UIScreen.main.bounds.height * 0.75
         )

         present(confirmPopup, animated: false) {
             confirmPopup.presentPopup()
         }
        
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        isEditMode.toggle()
        
        navigationItem.rightBarButtonItem?.title = isEditMode ? "Done" : "Edit"
        
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate & DataSource
extension CategoryManagementViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        return category.isExpanded ? category.subCategories.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories[indexPath.section]
        
        // أول صف في كل section هو الـ Category الرئيسي
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.configure(with: category.name, isExpanded: category.isExpanded)
            return cell
        } else {
            // الصفوف التانية هي الـ SubCategories
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
            let subCategory = category.subCategories[indexPath.row - 1]
            cell.configure(with: subCategory, isEditMode: isEditMode)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // لو دوست على Category رئيسي
        if indexPath.row == 0 {
            categories[indexPath.section].isExpanded.toggle()
            
            // تحميل الـ SubCategories بناءً على الـ Category المختار
            if categories[indexPath.section].isExpanded {
                loadSubCategories(for: indexPath.section)
            }
            
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
    
    private func loadSubCategories(for section: Int) {
        let categoryName = categories[section].name
        
        // تحميل الـ SubCategories بناءً على الـ Category
        switch categoryName {
        case "IT":
            categories[section].subCategories = ["Software", "Hardware", "Network"]
        case "HVAC":
            categories[section].subCategories = ["Heating", "Ventilation", "Air Conditioning"]
        case "Electrical":
            categories[section].subCategories = ["Lights", "Outlets", "Switches", "Elevators", "Sliding Doors"]
        case "Security":
            categories[section].subCategories = ["Fingerprint Sensors", "ID Card Sensors", "CCTV"]
        default:
            categories[section].subCategories = []
        }
    }
}

// MARK: - Models
struct Category {
    let name: String
    var isExpanded: Bool
    var subCategories: [String]
}

// MARK: - Category Cell
class CategoryCell: UITableViewCell {
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Container
        containerView.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 0.85, alpha: 1.0)
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Label
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .darkGray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // Arrow
        arrowImageView.tintColor = .darkGray
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            arrowImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20),
            
            nameLabel.leadingAnchor.constraint(equalTo: arrowImageView.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with name: String, isExpanded: Bool) {
        nameLabel.text = name
        
        // السهم: لتحت لو مفتوح، لليمين لو مقفول
        let arrowImage = isExpanded ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.right")
        arrowImageView.image = arrowImage
    }
}

// MARK: - SubCategory Cell
class SubCategoryCell: UITableViewCell {
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Label
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.textColor = .darkGray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // Toggle Switch (العلامة الخضراء)
        toggleSwitch.isOn = false
        toggleSwitch.isHidden = true // مخفية في البداية
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(toggleSwitch)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            containerView.heightAnchor.constraint(equalToConstant: 44),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: toggleSwitch.leadingAnchor, constant: -8),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    func configure(with name: String, isEditMode: Bool = false) {
        nameLabel.text = name
        toggleSwitch.isHidden = !isEditMode // تظهر فقط في وضع التعديل
    }
    
    func setEditMode(_ isEditMode: Bool) {
        toggleSwitch.isHidden = !isEditMode
    }
}
