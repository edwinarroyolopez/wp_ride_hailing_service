Sequel.migration do
  change do
    create_table(:rides) do
      primary_key :id
      Integer :rider_id, null: false
      Integer :driver_id, null: false
      Float :latitude_start, null: false
      Float :longitude_start, null: false
      Float :latitude_finish
      Float :longitude_finish
      String :status, null: false
      Float :distance
      Integer :elapsed_time
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end