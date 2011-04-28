# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should create an user' do
    Factory.create(:user)
  end

  it 'should destroy an user' do
    user = Factory.create(:user)
    user.destroy.should be_true
  end

  it 'should respond to has_role(Administrator)' do
    admin = Factory.create(:admin)
    admin.has_role?('Administrator').should be_true
  end

  it 'should respond to has_role(Librarian)' do
    librarian = Factory.create(:librarian)
    librarian.has_role?('Administrator').should be_false
    librarian.has_role?('Librarian').should be_true
    librarian.has_role?('User').should be_true
  end

  it 'should respond to has_role(User)' do
    user = Factory.create(:user)
    user.has_role?('Administrator').should be_false
    user.has_role?('Librarian').should be_false
    user.has_role?('User').should be_true
  end

  it 'should lock an user' do
    user = Factory.create(:user)
    user.locked = '1'
    user.save
    user.active_for_authentication?.should be_false
  end

  it 'should unlock an user' do
    user = Factory.create(:user)
    user.lock_access!
    user.locked = '0'
    user.save
    user.active_for_authentication?.should be_true
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = Factory.create(:user)
    user.expired_at.should be_nil
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = Factory.build(:user)
    user.user_group = Factory.create(:user_group, :valid_period_for_new_user => 10)
    user.save
    user.expired_at.should eq 10.days.from_now.end_of_day
  end
end
