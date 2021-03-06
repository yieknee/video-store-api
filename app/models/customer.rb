class Customer < ApplicationRecord
  # we do not validate the below because we never create a customer
  # validates :name, presence: true, uniqueness:{scope: :phone, message: 'Customer already exists in database'}
  # validates :registered_at, :address, :city, :postal_code, :phone, presence: true

  validates :videos_checked_out_count, numericality: {greater_than_or_equal_to: 0, only_integer: true }
  has_many :rentals
  has_many :videos, through: :rentals

  def increase_checked_out
    self.videos_checked_out_count += 1
    self.save
    return self
  end

  def decrease_checked_out
    self.videos_checked_out_count -= 1
    self.save
    return self
  end
end
