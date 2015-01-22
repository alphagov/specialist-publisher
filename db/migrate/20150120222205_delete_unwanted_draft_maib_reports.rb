class DeleteUnwantedDraftMaibReports < Mongoid::Migration
  def self.up
    ids = %w(
      b801d2e3-643c-4c28-b64e-1e3d9140d9db
      da6690fd-f473-45e4-88e1-9f4af9919919
      de07750a-bbd6-4509-864e-ceb30b9d3198
      baa3bc48-a601-485d-a951-38085be7756c
      37e3d5ae-616a-4342-a8c6-06bb2ecef35d
      4addd386-c6cb-4b32-92f6-5dbdf4eb5f2a
      21ac16fb-c187-49ee-aa88-4d0bc4afa19b
      11379ff2-9311-42db-9ee3-03b5ad8f7801
      1d870d46-da18-47ed-832a-ecbb7d256552
      10459e80-1315-431e-9db4-91e84a307516
      9e886543-e1cd-4ff6-bed3-5190a5231ffd
      1beb9b17-f9db-45aa-a816-d1d55b53a442
      6fbf2529-66df-449c-afd7-7feb37d06c1e
      7a477a92-3055-47df-b962-4bfec3a7135a
    )

    editions = SpecialistDocumentEdition.where(:document_id.in => ids)

    if editions.any? { |e| e.state != "draft" }
      raise "Aborting migration because some of the editions are not draft"
    end

    editions.each do |e|
      puts %(Deleting edition #{e.document_id}: "#{e.title}")
      e.delete
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
