# == Schema Information
#
# Table name: categories
#
#  id   :integer(4)      not null, primary key
#  name :string(255)
#

class Category < ActiveRecord::Base

  validates :name, :presence => true, :length => { :maximum => 50 }, :uniqueness => true

  attr_accessible :name

  scope :start_with, lambda { |word| where("name like ?", "#{word}%") }
  scope :sorted_by_name, order("name")

  self.per_page = 10

  after_save :clear_cache

  # Overrides genre string representation.
  #
  def to_s
    name
  end

  def clear_cache
    Rails.cache.delete Category.all_cache_key
  end

  class << self

    def fetch_all
      Rails.cache.fetch all_cache_key do
        Category.all
      end
    end

    def all_cache_key
      'categories:all'
    end

  end

end
