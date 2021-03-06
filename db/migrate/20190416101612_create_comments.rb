class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.belongs_to :user
      t.belongs_to :travel
      t.integer :partner
      t.integer :time
      t.integer :rating
      t.string :content

      t.timestamps
    end
  end
end
