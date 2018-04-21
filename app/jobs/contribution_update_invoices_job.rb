class ContributionUpdateInvoicesJob
  include SuckerPunch::Job

  def perform(contribution_id)
    ActiveRecord::Base.connection_pool.with_connection do
      @contribution = Contribution.find(contribution_id)
      @contribution.create_or_update_invoice!
    end
  end
end
