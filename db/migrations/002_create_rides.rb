Sequel.migration do
    change do
      create_table :rides do
        primary_key :id
        foreign_key :rider_id, :users, null: false
        foreign_key :driver_id, :users, null: false
        Float :latitude_start, null: false
        Float :longitude_start, null: false
        Float :latitude_finish
        Float :longitude_finish
        String :status, null: false, default: 'requested'
        DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
        DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      end
    end
  end