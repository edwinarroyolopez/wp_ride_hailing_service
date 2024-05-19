Sequel.migration do
    change do
      create_table(:transactions) do
        primary_key :id
        Integer :ride_id, null: false
        Integer :cost, null: false
        Integer :distance, null: false
        String :status, null: false
        String :id_external_transaction, null: false
  
        DateTime :created_at, null: false
        DateTime :updated_at, null: false
      end
    end
  end