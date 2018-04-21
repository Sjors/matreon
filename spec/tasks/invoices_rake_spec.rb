require 'spec_helper'

describe "invoices:process" do
  include_context "rake"

  it "should call :poll_unpaid!, :generate! and :email_unpaid_once! on Invoice" do
    expect(Invoice).to receive(:poll_unpaid!)
    expect(Invoice).to receive(:generate!)
    expect(Invoice).to receive(:email_unpaid_once!)
    subject.invoke
  end
end
