require 'rails_helper'

describe 'Member' do
  describe "#default_expiration_date" do
    it "uses the current year membership end date if it's before May" do
      Timecop.freeze Date.new(2025, 4, 25) do
        expect(Member.new.default_expiration_date).to eq("2025-05-31")
      end
    end

    it "uses the next year membership end date if it's during May" do
      Timecop.freeze Date.new(2025, 5, 1) do
        expect(Member.new.default_expiration_date).to eq("2026-05-31")
      end
    end

    it "uses the next year membership end date if it's after May" do
      Timecop.freeze Date.new(2025, 9, 26) do
        expect(Member.new.default_expiration_date).to eq("2026-05-31")
      end
    end
  end
end