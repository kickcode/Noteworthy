class AppDelegate
  include CDQ

  def applicationDidFinishLaunching(notification)
    cdq.setup

    buildMenu
    buildWindow

    @title_text = @layout.get(:title_text)
    @content_text = @layout.get(:content_text)

    @notes = Note.all
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
    Note.create(:title => title, :content => content, :created_at => Time.now)
    cdq.save
    @notes = Note.all
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
    result.stringValue = @notes.to_a[row].send(column.identifier.to_sym)
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
