class Subscription < ActiveRecord::Base
  has_many :subscribes, :dependent => :destroy
  has_many :works, :through => :subscribes
  belongs_to :user, :validate => true
  belongs_to :order_list, :validate => true

  validates_presence_of :title, :user
  validates_associated :user

  searchable do
    text :title, :note
    time :created_at
    time :updated_at
    integer :work_ids, :multiple => true
  end

  def self.per_page
    10
  end

  def subscribed(work)
    subscribes.where(:work_id => work.id).first
  end

end
