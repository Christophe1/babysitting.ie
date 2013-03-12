# == Schema Information
#
# Table name: genres
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Genre < ActiveRecord::Base

  has_and_belongs_to_many :films

  validates :name, :presence => true, :length => { :maximum => 50 }, :uniqueness => true

  attr_accessible :name

  scope :start_with, lambda { |word| where("name like ?", "#{word}%") }
  scope :sorted_by_name, order("name")

  self.per_page = 10

  # Overrides genre string representation.
  #
  def to_s
    name
  end
end
