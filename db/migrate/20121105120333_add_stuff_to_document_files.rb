class AddStuffToDocumentFiles < ActiveRecord::Migration
  def change
    add_column :document_files, :format, :string
    add_column :document_files, :sha1, :string
    add_column :document_files, :size, :integer
  end
end
