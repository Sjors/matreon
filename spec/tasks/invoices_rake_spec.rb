require 'spec_helper'

describe "invoices:generate_and_send" do
  include_context "rake"

  it "should call :generate! and :email! on Invoice" do
    expect(Invoice).to receive(:generate!)
    expect(Invoice).to receive(:email!)
    subject.invoke
  end
end
