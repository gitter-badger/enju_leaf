require 'spec_helper'

describe CheckoutsController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:admin)
      5.times do
        FactoryGirl.create(:user)
      end
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all checkouts as @checkouts" do
        get :index
        assigns(:checkouts).should eq(Checkout.not_returned.order('created_at DESC').page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should get index" do
        get :index
        response.should be_success
      end

      it "should get index csv" do
        get :index, :format => 'csv'
        response.should be_success
      end

      it "should get index rss" do
        get :index, :format => 'rss'
        response.should be_success
      end

      it "should get overdue index" do
        get :index, :view => 'overdue'
        response.should be_success
      end

      it "should get overdue index with nunber of days_overdue" do
        get :index, :view => 'overdue', :days_overdue => 2
        response.should be_success
        assigns(:checkouts).size.should > 0
      end

      it "should get overdue index with invalid number of days_overdue" do
        get :index, :view => 'overdue', :days_overdue => 'invalid days'
        response.should be_success
        assigns(:checkouts).size.should > 0
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "assigns all checkouts as @checkouts" do
        get :index
        assigns(:checkouts).should eq(@user.checkouts.not_returned.order('created_at DESC').page(1))
      end

      it "should be redirected if an username is not specified" do
        get :index
        assigns(:checkouts).should be_empty
        response.should be_success
      end

      it "should be forbidden if other's username is specified" do
        user = FactoryGirl.create(:user)
        get :index, :user_id => user.username
        assigns(:checkouts).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns nil as @checkouts" do
        get :index
        assigns(:checkouts).should be_nil
        response.should redirect_to(new_user_session_url)
      end

      it "assigns his own checkouts as @checkouts" do
        token = "AVRjefcBcey6f1WyYXDl"
        user = User.where(:checkout_icalendar_token => token).first
        get :index, :icalendar_token => token
        assigns(:checkouts).should eq user.checkouts.not_returned.order('created_at DESC').page(1)
        response.should be_success
      end

      it "should get ics template" do
        token = "AVRjefcBcey6f1WyYXDl"
        user = User.where(:checkout_icalendar_token => token).first
        get :index, :icalendar_token => token, :format => :ics
        assigns(:checkouts).should eq user.checkouts.not_returned.order('created_at DESC').page(1)
        response.should be_success
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @checkout = checkouts(:checkout_00003)
      @attrs = {:due_date => 1.day.from_now}
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(assigns(:checkout))
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(assigns(:checkout))
        end
      end

      describe "with invalid params" do
        it "assigns the checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          assigns(:checkout).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => checkouts(:checkout_00001).id, :checkout => @attrs
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => checkouts(:checkout_00001).id, :checkout => @attrs
          assigns(:checkout).should eq(checkouts(:checkout_00001))
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => checkouts(:checkout_00001).id, :checkout => @attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "should be forbidden" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @checkout = checkouts(:checkout_00003)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
      end

      it "redirects to the checkouts list" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
        response.should redirect_to(user_checkouts_url(@checkout.user))
      end

      it "should destroy other user's checkout" do
        delete :destroy, :id => 3
        response.should redirect_to user_checkouts_url(assigns(:checkout).user)
      end
  
      it "should not destroy missing checkout" do
        delete :destroy, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
      end

      it "redirects to the checkouts list" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
        response.should redirect_to(user_checkouts_url(@checkout.user))
      end

      it "should destroy other user's checkout" do
        delete :destroy, :id => 1
        response.should redirect_to user_checkouts_url(assigns(:checkout).user)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested checkout" do
        delete :destroy, :id => checkouts(:checkout_00001).id
      end

      it "should be forbidden" do
        delete :destroy, :id => checkouts(:checkout_00001).id
        response.should be_forbidden
      end

      it "should destroy my checkout" do
        delete :destroy, :id => 3
        response.should redirect_to user_checkouts_url(users(:user1))
      end
    end

    describe "When not logged in" do
      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
      end

      it "should be forbidden" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
