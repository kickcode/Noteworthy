schema "0001 initial" do
  entity "Note" do
    string :title, optional: false
    string :content, optional: false
    datetime :created_at, optional: false
  end
end
