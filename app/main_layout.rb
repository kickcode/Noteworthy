class MainLayout < MotionKit::Layout
  FORM_HEIGHT = 100
  TITLE_HEIGHT = 30
  CONTENT_HEIGHT = 70
  BUTTON_WIDTH = 70
  BUTTON_HEIGHT = 30

  def layout
    add NSView, :form do
      constraints do
        width.equals(:superview)
        height.is(FORM_HEIGHT)

        min_left.is 0
        min_top.is 0
      end

      add NSTextField, :title_text do
        placeholderString "Enter note title"

        constraints do
          width.equals(:superview)
          height.is(TITLE_HEIGHT)

          min_left.is 0
          min_top.is 0
        end
      end

      add NSTextField, :content_text do
        placeholderString "Enter note content"

        constraints do
          width.equals(:superview)
          height.is(CONTENT_HEIGHT)

          min_left.is 0
          min_top.is TITLE_HEIGHT
        end
      end

      add NSButton, :save_button do
        title "Save"

        constraints do
          width.equals(BUTTON_WIDTH)
          height.is(BUTTON_HEIGHT)

          min_right.is 0
          min_bottom.is 0
        end
      end
    end
    add NSScrollView, :scroll_view do
      has_vertical_scroller true
      constraints do
        width.equals(:superview)
        height.equals(:superview).minus(FORM_HEIGHT)

        min_top.is FORM_HEIGHT
      end

      table_view = add(NSTableView, :table_view) do
        row_height 25

        add_column "title" do
          title "Title"
          min_width 150
        end

        add_column "content" do
          title "Content"
          min_width 600
        end

        add_column "created_at" do
          title "Created"
        end
      end
      document_view table_view
    end
  end
end
