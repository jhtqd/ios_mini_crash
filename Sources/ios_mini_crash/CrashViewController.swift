//
//  CrashViewController.swift
//
//  Created by jiaohaitao on 2021/5/12.
//
//  用于显示Crash栈的 ViewController

#if os(iOS)

import UIKit

//此页面可添加其他功能，例如：发邮件或提交至Server
final class CrashViewController: UIViewController {
    private var crashStack : [String] = []
    var textView: UITextView?
    
    public convenience init(crashStack:[String]){
        self.init(nibName: nil, bundle: nil)
        self.crashStack = crashStack
    }

    override func loadView() {
        super.loadView()
        textView = UITextView.init(frame: CGRect(origin: .zero, size: view.frame.size))
        view.addSubview(self.textView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.textView?.text = crashStack.joined(separator: "\n")
    }
}

#endif
