namespace :invoices do :env
  desc "Generate, update and email invoices when needed"
  task :process => :environment do
    # Check if any pending invoice has been paid:
    Invoice.poll_unpaid!

    # Generate invoices
    Invoice.generate!

    # Email invoices
    Invoice.email!
  end
end
