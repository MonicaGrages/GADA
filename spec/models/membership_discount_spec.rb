require 'rails_helper'

RSpec.describe MembershipDiscount, type: :model do
  describe ".active" do
    let!(:active_discount) { MembershipDiscount.create!(discount_amount_in_dollars: 10, start_at: 2.days.ago, end_at: Date.tomorrow.end_of_day) }
    let!(:inactive_discount) { MembershipDiscount.create!(discount_amount_in_dollars: 10, start_at: 12.days.ago, end_at: 2.days.ago) }

    it "includes only discounts whose start and end range include the current time" do
      expect(MembershipDiscount.active.pluck(:id)).to eq([active_discount.id])
    end
  end
end
