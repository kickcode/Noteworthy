class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow

    @title_text = @layout.get(:title_text)
    @content_text = @layout.get(:content_text)

    @notes = []
    @table_view = @layout.get(:table_view)
    @table_view.delegate = self
    @table_view.dataSource = self

    @save_button = @layout.get(:save_button)
    @save_button.target = self
    @save_button.action = 'note_save:'
  end

  def note_save(sender)
    title = @title_text.stringValue
    content = @content_text.stringValue
    return if title.nil? || title.empty? || content.nil? || content.empty?
    @notes << {:title => title, :content => content}
    @table_view.reloadData
    @title_text.stringValue = ""
    @content_text.stringValue = ""
  end

  def numberOfRowsInTableView(table_view)
    @notes.length
  end

  def tableView(table_view, viewForTableColumn: column, row: row)
    result = table_view.makeViewWithIdentifier(column.identifier, owner: self)
    if result.nil?
      result = NSTextField.alloc.initWithFrame([[0, 0], [column.width, 0]])
      result.identifier = column.identifier
      result.editable = false
    end
    result.stringValue = @notes[row][column.identifier.to_sym]
    result
  end

  def buildWindow
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless

    @layout = MainLayout.new
    @mainWindow.contentView = @layout.view
  end
end
