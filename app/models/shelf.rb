class Shelf < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  scope :real, :conditions => ['library_id != 1']
  belongs_to :library, :validate => true
  has_many :items, :include => [:circulation_status]
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy

  validates_associated :library
  validates_presence_of :library
  validates_uniqueness_of :display_name

  acts_as_list :scope => :library

  def self.per_page
    10
  end

  def web_shelf?
    return true if self.id == 1
    false
  end

  def self.web
    Shelf.find(1)
  end

  def first?
    # 必ずposition順に並んでいる
    return true if library.shelves.first.position == position
    false
  end

  def localized_display_name
    display_name.localize
  end
end
