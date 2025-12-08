require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_date" do
    it "returns year string for Date" do
      expect(helper.format_date(Date.new(2020, 1, 1))).to eq("2020")
    end

    it "parses string dates" do
      expect(helper.format_date("2019-05-04")).to eq("2019")
    end

    it "returns nil for blank or invalid" do
      expect(helper.format_date(nil)).to be_nil
      expect(helper.format_date("bad")).to be_nil
    end
  end

  describe "#poster_url_for and #poster_is_placeholder?" do
    it "returns placeholder for blank path" do
      url = helper.poster_url_for(nil)
      expect(helper.poster_is_placeholder?(url)).to be(true)
    end

    it "returns tmdb url for path" do
      url = helper.poster_url_for("/abc.jpg")
      expect(url).to eq(TmdbService.poster_url("/abc.jpg"))
      expect(helper.poster_is_placeholder?(url)).to be(false)
    end
  end
end
