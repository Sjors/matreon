namespace :invoices do :env
  desc "Generate and email invoices one month after the previous one"
  task :generate_and_send => :environment do
    # Generate invoices
    Invoice.generate!

    # Email invoices
    Invoice.email!
  end
end
