require 'spec_helper'

describe("Integration Tests") do
  it "writes the redirect pages for collection items which are outputted" do
    expect(dest_dir("articles", "redirect-me-plz.html")).to exist
    expect(dest_dir("articles", "23128432159832", "mary-had-a-little-lamb#{forced_output_ext}")).to exist
  end

  it "doesn't write redirect pages for collection items which are not outputted" do
    expect(dest_dir("authors")).not_to exist
    expect(dest_dir("kansaichris")).not_to exist
  end
end
