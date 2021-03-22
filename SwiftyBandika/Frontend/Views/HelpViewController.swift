//
//  HelpViewController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 10.12.20.
//

import Cocoa

class HelpViewController: NSViewController {
    
    let texts = ["SwiftyBandika is a full web server and CMS.",
                 " ",
                 "The frontend (this app) has two panels: the server and the layout panel.",
                 "On the server panel you can set the basic configuration and start and stop the HTTP server.",
                 "You can also create and restore backups. So if you make changes, you should create a backup first.",
                 "Backups include all data, settings, designs and templates.",
                 "Make sure the server ist stopped, before you restore a backup.",
                 "The right side of this panel shows the log with all important runtime information.",
                 "Warnings and errors are highlighted.",
                 " ",
                 "On the layout panel you can edit your design including the logo, style sheet and style images.",
                 "You can also create and update your templates using HTML and special <spg:...> tags.",
                 "You will always need a default master template, so you cannot delete it.",
                 "Templates are always embedded in an xml tag which holds the template's attributes.",
                 "The starting point for the layout and its templates is the current blue one, which is also used for administration pages.",
                 " ",
                 "All other instructions how to use this CMS you will find on the default home page after you started the server.",
                 "The login for the super admin is 'root' with the password 'pass'. For production you should obviously change this."]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.frame = CGRect(x: 0, y: 0, width: 800, height: 270)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        let font = NSFont.systemFont(ofSize: 14)
        for text in texts{
            let field = NSTextField(wrappingLabelWithString: text)
            field.font = font
            stack.addArrangedSubview(field)
        }
        view.addSubview(stack)
        stack.fillSuperview(insets: Insets.defaultInsets)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
