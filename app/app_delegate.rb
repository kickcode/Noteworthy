class AppDelegate
  include CDQ

  KV_SORT_ORDER = 'sort_order'
  KV_SORT_BY = 'sort_by'

  def applicationDidFinishLaunching(notification)
    cdq.setup(:store => cdq.stores.new(:icloud => true, :model_manager => cdq.models))

    @kv_store = NSUbiquitousKeyValueStore.defaultStore

    buildMenu
    buildWindow

    @title_text = @layout.get(:title_text)
    @content_text = @layout.get(:content_text)

    self.load_notes
    @table_view = @layout.get(:table_view)
    @table_view.delegate = self
    @table_view.dataSource = self

    @save_button = @layout.get(:save_button)
    @save_button.target = self
    @save_button.action = 'note_save:'

    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'icloud_did_change:', name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: cdq.stores.current)
  end

  def icloud_did_change(notification)
    cdq.contexts.current.performBlock(Proc.new do
      cdq.contexts.current.mergeChangesFromContextDidSaveNotification(notification)
      self.load_notes
    end)
  end

  def applicationWillTerminate(application)
    @kv_store.synchronize
  end

  def load_notes(sort_by = nil)
    @sort_order ||= (@kv_store.stringForKey(KV_SORT_ORDER) || 'descending').to_sym
    @sort_order = (@sort_order == :descending ? :ascending : :descending) if @sort_by && @sort_by == sort_by
    @sort_by ||= (@kv_store.stringForKey(KV_SORT_BY) || 'created_at').to_sym
    @sort_by = sort_by unless sort_by.nil?
    @notes = Note.sort_by(@sort_by, :order => @sort_order).to_a
    self.save_settings!
    Dispatch::Queue.main.async { @table_view.reloadData if @table_view }
  end

  def save_settings!
    @kv_store.setObject(@sort_order, forKey: KV_SORT_ORDER)
    @kv_store.setObject(@sort_by, forKey: KV_SORT_BY)
  end

  def note_save(sender)
    title = @title_text.stringValue
    content = @content_text.stringValue
    return if title.nil? || title.empty? || content.nil? || content.empty?
    Note.create(:title => title, :content => content, :created_at => Time.now)
    cdq.save
    self.load_notes
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
    if column.identifier == "created_at"
      result.stringValue = @notes[row].created_at.strftime("%a %d %b %Y %I:%M:%S%p")
    else
      result.stringValue = @notes[row].send(column.identifier.to_sym)
    end
    result
  end

  def tableView(table_view, didClickTableColumn: column)
    self.load_notes(column.identifier.to_sym)
  end

  def buildWindow
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [960, 720]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless

    @layout = MainLayout.new
    @mainWindow.contentView = @layout.view
  end
end
