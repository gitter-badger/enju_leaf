# -*- encoding: utf-8 -*-
require 'spec_helper'
  
describe UserExportFile do
  fixtures :all
  
  it "should export in background" do
    message_count = Message.count
    file = UserExportFile.new
    file.user = users(:admin)
    file.save
    UserExportFileQueue.perform(file.id).should be_truthy
    Message.count.should eq message_count + 1
    Message.order(:id).last.subject.should eq 'エクスポートが完了しました'
  end
end

# == Schema Information
#
# Table name: user_export_files
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  user_export_file_name    :string(255)
#  user_export_content_type :string(255)
#  user_export_file_size    :integer
#  user_export_updated_at   :datetime
#  executed_at              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
