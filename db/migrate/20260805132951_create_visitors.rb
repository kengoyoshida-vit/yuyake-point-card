class CreateVisitors < ActiveRecord::Migration[8.1]
  def change
    create_table :visitors do |t|
      t.string :line_user_id
      t.string :card_number
      t.string :display_name
      t.string :avatar_url
      t.integer :category
      t.string :company_name
      t.integer :gender
      t.integer :age_band
      t.integer :resident
      t.datetime :profile_prompted_at

      t.timestamps
    end
    add_index :visitors, :line_user_id, unique: true
    add_index :visitors, :card_number, unique: true

    add_check_constraint :visitors,
      "line_user_id IS NOT NULL OR card_number IS NOT NULL",
      name: "visitors_line_user_id_or_card_number_check"
  end
end
