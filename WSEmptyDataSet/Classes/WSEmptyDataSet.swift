//
//  WSEmptyDataSet.swift
//  YoyoPkRoom
//
//  Created by wangsong on 2018/3/1.
//  Copyright © 2018年 wangsong. All rights reserved.
//

import UIKit
import SnapKit

//使用方法
//init(source:, delegate: emptyDataSet: )方法 创建WSEmptyDataSet对象
//通过实现WSEmptyDataSetSource中的协议方法来配置空数据集
//在合适的时机调用reloadEmptyDataSet方法来刷新WSEmptyDataSet

@objc enum WSEmptyDataSetState: Int {
    case none  // 默认状态，相当于loaded
    case loading    // 这个状态中会展示加载动画
    case loaded      // 这个状态中会根据数据源显示/隐藏空页面
    case error         // 这个状态是网络请求错误，会根据数据源显示错误动画
}

class WSEmptyDataSet: NSObject {
    
    //MARK: - Life Cycle
    
    init(source: WSEmptyDataSetSource?, delegate: WSEmptyDataSetDelegate?, emptyDataSet: UIScrollView) {
        super.init()
        
        emptyDataSetSource = source
        emptyDataSetDelegate = delegate
        self.emptyDataSet = emptyDataSet
        emptyDataSet.addSubview(self.emptyDataView)
        
        self.emptyDataView.snp.makeConstraints({ (make) in
            make.top.equalTo(emptyDataSet)
            make.left.equalTo(emptyDataSet)
            make.height.equalTo(emptyDataSet)
            make.width.equalTo(emptyDataSet)
        })
    }
    
    //MARK: - Var
    var emptyDataSetState: WSEmptyDataSetState = .none
    
    private weak var emptyDataSetSource: WSEmptyDataSetSource?
    private weak var emptyDataSetDelegate: WSEmptyDataSetDelegate?
    private weak var emptyDataSet: UIScrollView?
    
    //MARK: - Lazy
    
    lazy var emptyDataView: YoEmptyDataView = {
        var obj = YoEmptyDataView(frame: .zero)
        obj.backgroundColor = .white
        obj.onClickButtonClosure = { [weak self] in
            self?.emptyDataSetDelegate?.onClickEmptyDataViewButton?(button: obj.button)
        }
        return obj
    }()
    
    //MARK: - Public
    
    func reloadEmptyDataSet(emptyDataSet: UIScrollView, state: WSEmptyDataSetState = .loaded) {
        if emptyDataSet.itemCount() > 0 {
            emptyDataView.isHidden = true
            
        } else {
            emptyDataView.isHidden = false
            p_reloadEmptyDataSetFromSource(state: state)
        }
    }
    
    //MARK: - Private
    
    func p_reloadEmptyDataSetFromSource(state: WSEmptyDataSetState) {
        guard emptyDataSetSource != nil else {
            return
        }
        
        let attributeTitle = emptyDataSetSource?.title?(emptyDataSet: emptyDataSet, state: state)
        emptyDataView.setAttributeTitle(attributeTitle: attributeTitle)
        
        let detailAttributeTitle = emptyDataSetSource?.detailTitle?(emptyDataSet: emptyDataSet, state: state)
        emptyDataView.setDetailAttributeTiele(detailAttributeTitle: detailAttributeTitle)
        
        let image = emptyDataSetSource?.image?(emptyDataSet: emptyDataSet, state: state)
        let imageList = emptyDataSetSource?.imageList?(emptyDataSet: emptyDataSet, state: state)
        
        emptyDataView.imageView.image = nil
        emptyDataView.imageView.animationImages = nil
        
        if let imageList = imageList, imageList.count > 0 {
            // 帧动画
            emptyDataView.imageView.animationDuration = 0.8
            emptyDataView.imageView.animationImages = imageList
            emptyDataView.imageView.animationRepeatCount = 0
            emptyDataView.imageView.startAnimating()
        }
        else if let image = image {
            // 如果数据源指定了图片就使用指定图片
            emptyDataView.imageView.image = image
        }
        
        let imageSize = emptyDataSetSource?.imageSize?(emptyDataSet: emptyDataSet, state: state)
        if let imageSize = imageSize {
            // 如果数据源指定了图片尺寸使用指定尺寸
            emptyDataView.setImageSize(size: imageSize)
        }
        
        if state == .loading {
            // loading状态不显示button
            emptyDataView.resetButton()
            return
        }
        
        let buttonSize = emptyDataSetSource?.buttonSize?(emptyDataSet: emptyDataSet)
        if let buttonSize = buttonSize {
            // 如果数据源指定了按钮尺寸就使用指定尺寸
            emptyDataView.setButtonSize(size: buttonSize)
        }
        
        let customButton = emptyDataSetSource?.customButton?(emptyDataSet: emptyDataSet)
        
        if let customButton = customButton {
            // 如果数据源提供了自定义button，就使用自定义button
            emptyDataView.setCustomButton(customButton: customButton)
        } else {
            // 使用数据源指定的button属性
            let buttonNormalTitle = emptyDataSetSource?.buttonTitle?(emptyDataSet: emptyDataSet, state: .normal)
            let buttonHighlightTitle = emptyDataSetSource?.buttonTitle?(emptyDataSet: emptyDataSet, state: .highlighted)
            let buttonSelectedTitle = emptyDataSetSource?.buttonTitle?(emptyDataSet: emptyDataSet, state: .selected)
            let buttonDisableTitle = emptyDataSetSource?.buttonTitle?(emptyDataSet: emptyDataSet, state: .disabled)
            emptyDataView.setButtonAttributeTitle(attributeTitle: buttonNormalTitle, state: .normal)
            emptyDataView.setButtonAttributeTitle(attributeTitle: buttonHighlightTitle, state: .highlighted)
            emptyDataView.setButtonAttributeTitle(attributeTitle: buttonSelectedTitle, state: .selected)
            emptyDataView.setButtonAttributeTitle(attributeTitle: buttonDisableTitle, state: .disabled)
            
            let buttonNormalBackgroundImage = emptyDataSetSource?.buttonBackgroundImage?(emptyDataSet: emptyDataSet, state: .normal)
            let buttonHighlightBackgroundImage = emptyDataSetSource?.buttonBackgroundImage?(emptyDataSet: emptyDataSet, state: .highlighted)
            let buttonSelectedBackgroundImage = emptyDataSetSource?.buttonBackgroundImage?(emptyDataSet: emptyDataSet, state: .selected)
            let buttonDisableBackgroundImage = emptyDataSetSource?.buttonBackgroundImage?(emptyDataSet: emptyDataSet, state: .disabled)
            
            emptyDataView.setButtonBackgroundImage(image: buttonNormalBackgroundImage, state: .normal)
            emptyDataView.setButtonBackgroundImage(image: buttonHighlightBackgroundImage, state: .highlighted)
            emptyDataView.setButtonBackgroundImage(image: buttonSelectedBackgroundImage, state: .selected)
            emptyDataView.setButtonBackgroundImage(image: buttonDisableBackgroundImage, state: .disabled)
            
            let buttonBackgroundColor = emptyDataSetSource?.buttonBackgroundColor?(emptyDataSet: emptyDataSet)
            emptyDataView.setButtonBackgroundColor(color: buttonBackgroundColor)
        }
        
        let verticalOffset = emptyDataSetSource?.verticalOffset?(emptyDataSet: emptyDataSet)
        if let verticalOffset = verticalOffset {
            emptyDataView.verticalOffset = verticalOffset
        }
    }
}


//MARK: - YoEmptyDataView
class YoEmptyDataView: UIView {
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        verticalOffset = 0
        imageSize = CGSize(width: 100, height: 100)
        buttonSize = CGSize(width: 140, height: 36)
        
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Var
    
    var onClickButtonClosure: ()->() = {
        return
    }
    var verticalOffset: CGFloat = 0
    var imageSize: CGSize = CGSize(width: 100, height: 100)
    var buttonSize: CGSize = CGSize(width: 140, height: 36)
    
    var customButton: UIButton?
    
    //MARK: - Lazy
    
    // 容器
    lazy var contentView: UIView = {
        var contentView = UIView()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(detailLabel)
        contentView.addSubview(button)
        
        return contentView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = .gray
        titleLabel.numberOfLines = 1
        
        return titleLabel
    }()
    
    // 图片
    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        
        return imageView
    }()
    
    // 描述
    lazy var detailLabel: UILabel = {
        var detailLabel = UILabel()
        detailLabel.textAlignment = .center
        detailLabel.textColor = .lightGray
        detailLabel.numberOfLines = 0
        
        return detailLabel
    }()
    
    // 按钮
    lazy var button: UIButton = {
        return createButton()
    }()
    
    //MARK: - Action
    
    @objc func onClickButton() {
        onClickButtonClosure()
    }
    
    //MARK: - Layout
    override func updateConstraints() {
        contentView.snp.updateConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        imageView.snp.updateConstraints { (make) in
            make.size.equalTo(imageSize)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(verticalOffset)
        }
        
        titleLabel.snp.updateConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        detailLabel.snp.updateConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        let tempButton: UIButton?
        if let customButton = customButton {
            tempButton = customButton
        } else {
            tempButton = button
        }
        
        var tempButtonSize: CGSize?
        if ((tempButton?.frame.size) != .zero) {
            tempButtonSize = tempButton?.frame.size
        } else {
            tempButtonSize = buttonSize
        }
        tempButton?.snp.updateConstraints { (make) in
            make.top.equalTo(detailLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(tempButtonSize!)
        }
        super.updateConstraints()
    }
    
    //MARK: - Public
    
    func setAttributeTitle(attributeTitle: NSAttributedString?) {
        titleLabel.attributedText = attributeTitle
    }
    
    func setDetailAttributeTiele(detailAttributeTitle: NSAttributedString?) {
        detailLabel.attributedText = detailAttributeTitle
    }
    
    func setImage(image: UIImage?) {
        imageView.image = image
    }
    
    func setButtonAttributeTitle(attributeTitle: NSAttributedString?,  state: UIControlState) {
        showButton()
        
        if state == .normal && attributeTitle == nil {
            button.isHidden = true
        } else {
            button.isHidden = false
        }
        button.setAttributedTitle(attributeTitle, for: state)
    }
    
    func setButtonBackgroundImage(image: UIImage?, state: UIControlState) {
        showButton()
        
        button.setBackgroundImage(image, for: state)
    }
    
    func setButtonBackgroundColor(color: UIColor?) {
        showButton()
        
        button.backgroundColor = color
    }
    
    func setVerticalOffset(offset: CGFloat?) {
        if let offset = offset {
            verticalOffset = offset
        }
        YoEmptyDataView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setNeedsUpdateConstraints), object: nil)
        setNeedsUpdateConstraints()
    }
    
    func setImageSize(size: CGSize?) {
        if let size = size {
            imageSize = size
        }
        YoEmptyDataView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setNeedsUpdateConstraints), object: nil)
        setNeedsUpdateConstraints()
    }
    
    func setButtonSize(size: CGSize?) {
        showButton()
        
        if let size = size {
            buttonSize = size
        }
        YoEmptyDataView.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setNeedsUpdateConstraints), object: nil)
        setNeedsUpdateConstraints()
    }
    
    func setCustomButton(customButton: UIButton?) {
        if let customButton = customButton {
            self.customButton = customButton
            self.contentView.addSubview(customButton)
            self.button.isHidden = true
        } else {
            self.customButton?.removeFromSuperview()
        }
    }
    
    func resetButton() {
        button.setAttributedTitle(nil, for: .normal)
        button.setBackgroundImage(nil, for: .normal)
        button.setTitle(nil, for: .normal)
        button.backgroundColor = nil
        
        customButton?.isHidden = true
        button.isHidden = true
    }
    
    func createButton() -> UIButton {
        button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(onClickButton), for: .touchUpInside)
        
        return button
    }
    
    func showButton() {
        if button.isHidden {
            button.isHidden = false
        }
    }
}

//MARK: - WSEmptyDataSetSource协议
@objc protocol WSEmptyDataSetSource {
    // title
    @objc optional func title(emptyDataSet: UIScrollView?, state: WSEmptyDataSetState) -> NSAttributedString?
    // subTitle
    @objc optional func detailTitle(emptyDataSet: UIScrollView?, state: WSEmptyDataSetState) -> NSAttributedString?
    // image
    @objc optional func image(emptyDataSet: UIScrollView?, state: WSEmptyDataSetState) -> UIImage?
    // animation
    @objc optional func imageList(emptyDataSet: UIScrollView?, state: WSEmptyDataSetState) -> Array<UIImage>?
    @objc optional func imageSize(emptyDataSet: UIScrollView?, state: WSEmptyDataSetState) -> CGSize
    // buttonTitle
    @objc optional func buttonTitle(emptyDataSet: UIScrollView?, state: UIControlState) -> NSAttributedString?
    @objc optional func buttonSize(emptyDataSet: UIScrollView?) -> CGSize
    
    // buttonBackground
    @objc optional func buttonBackgroundImage(emptyDataSet: UIScrollView?, state: UIControlState) -> UIImage?
    // backgroundColor
    @objc optional func buttonBackgroundColor(emptyDataSet: UIScrollView?) -> UIColor
    
    // verticalOffset
    @objc optional func verticalOffset(emptyDataSet: UIScrollView?) -> CGFloat
    // custom button
    @objc optional func customButton(emptyDataSet: UIScrollView?) -> UIButton?
}

//MARK: - WSEmptyDataSetDelegate协议
@objc protocol WSEmptyDataSetDelegate {
    @objc optional func onClickEmptyDataViewButton(button: UIButton?)
}

//MARK: - 获取cell个数
extension UIScrollView {
    
    // cell个数
    func itemCount() -> Int {
        var items: Int = 0
        
        guard (self is UITableView) || (self is UICollectionView) else {
            return items
        }
        
        if self is UITableView {
            
            let sections: Int = 1
            
            let tableViewSelf = self as! UITableView
            
            let dataSource = tableViewSelf.dataSource
            
            guard dataSource != nil else {
                return items
            }
            
            for section in 0 ..< sections {
                items = items + (dataSource?.tableView(tableViewSelf, numberOfRowsInSection: section))!
            }
            
            return items
        }
        
        if self is UICollectionView {
            
            let sections: Int = 1
            
            let collectionViewSelf = self as! UICollectionView
            
            let dataSource = collectionViewSelf.dataSource
            
            guard dataSource != nil else {
                return items
            }
            
            for section in 0 ..< sections {
                items = items + (dataSource?.collectionView(collectionViewSelf, numberOfItemsInSection: section))!
            }
            
            return items
        }
        
        return items
    }
}

