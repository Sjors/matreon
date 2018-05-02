require 'spec_helper'

describe "podcast:fetch" do
  include_context "rake"

  it "should call :fetch! on Podcast" do
    expect(Podcast).to receive(:fetch!)
    subject.invoke
  end
end
