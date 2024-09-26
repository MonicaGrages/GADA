class MembershipDiscount < ApplicationRecord
  validates :discount_amount_in_dollars, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: Setting.instance.rd_membership_price
  }
  validates :membership_type, inclusion: { in: %w(RD Student),
                                           message: "must be either RD or Student" }
  validates :start_at, presence: true
  validates :end_at, numericality: { greater_than: Proc.new {|discount| discount.start_at },
                                     message: "must be after Start at" }

  scope :active, -> { where("start_at <= ? and end_at >= ?", Time.zone.now, Time.zone.now) }
  scope :rd, -> { where("membership_type ilike ?", 'RD') }
  scope :student, -> { where("membership_type ilike ?", 'Student') }

  def self.best_active_rd_discount
    MembershipDiscount.active.rd.order("discount_amount_in_dollars ASC").last
  end

  def self.best_active_student_discount
    MembershipDiscount.active.rd.order("discount_amount_in_dollars ASC").last
  end
end
