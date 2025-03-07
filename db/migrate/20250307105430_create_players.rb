class CreatePlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :players do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :save_file_path

      t.timestamps
    end
  end
end
