Sequel.migration do
    change do
      create_table(:payment_sources) do
        primary_key :id
        Integer :rider_id, null: false
        String :token, null: false
        DateTime :created_at, null: false
        DateTime :updated_at, null: false
      end
    end
  end