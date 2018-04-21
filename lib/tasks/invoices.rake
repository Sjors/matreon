namespace :invoices do :env
  desc "Generate, update and email invoices when needed"
  task :process => :environment do
    # Generate invoices
    Invoice.generate!

    # Email invoices
    Invoice.email!
  end
end
