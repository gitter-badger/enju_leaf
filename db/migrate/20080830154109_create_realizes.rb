class CreateRealizes < ActiveRecord::Migration
  def change
    create_table :realizes do |t|
      t.references :patron, :null => false
      t.references :expression, :null => false
      t.integer :position
      t.string :type

      t.timestamps
    end
    add_index :realizes, :patron_id
    add_index :realizes, :expression_id
    add_index :realizes, :type
  end
end
