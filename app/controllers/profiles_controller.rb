# -*- encoding: utf-8 -*-
class ProfilesController < ApplicationController
  load_and_authorize_resource except: [:index, :create]
  authorize_resource only: [:index, :create]
  before_filter :prepare_options, only: [:new, :edit]

  # GET /profiles
  # GET /profiles.json
  def index
    query = flash[:query] = params[:query].to_s
    @query = query.dup
    @count = {}

    sort = {sort_by: 'created_at', order: 'desc'}
    case params[:sort_by]
    when 'username'
      sort[:sort_by] = 'username'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    query = params[:query]
    page = params[:page] || 1
    role = current_user.try(:role) || Role.default_role

    search = Profile.search
    search.build do
      fulltext query if query
      order_by sort[:sort_by], sort[:order]
    end
    search.query.paginate(page.to_i, Profile.default_per_page)
    @profiles = search.execute!.results
    @count[:query_result] = @profiles.total_entries

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    if @profile.user == current_user
      redirect_to my_account_url
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
    @profile.user = User.new
    @profile.user_group = current_user.profile.user_group
    @profile.library = current_user.profile.library
    @profile.locale = current_user.profile.locale

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    if @profile.user == current_user
      redirect_to edit_my_account_url
      return
    end
    if @profile.user.try(:locked_at?)
      @profile.user.locked = true
    end
  end

  # POST /profiles
  # POST /profiles.json
  def create
    if current_user.has_role?('Librarian')
      @profile = Profile.new(params[:profile], as: :admin)
      if @profile.user
        @profile.user.operator = current_user
        password = @profile.user.set_auto_generated_password
      end
    else
      @profile = Profile.new(params[:profile])
    end

    respond_to do |format|
      if @profile.save
        if @profile.user
          @profile.user.role = Role.where(name: 'User').first
          flash[:temporary_password] = password
        end
        format.html { redirect_to @profile, notice: t('controller.successfully_created', model: t('activerecord.models.profile')) }
        format.json { render json: @profile, status: :created, location: @profile }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    if current_user.has_role?('Librarian')
      @profile.update_attributes(params[:profile], as: :admin)
    else
      @profile.update_attributes(params[:profile])
    end
    if @profile.user
      if @profile.user.auto_generated_password == "1"
        @profile.user.set_auto_generated_password
        flash[:temporary_password] = @profile.user.password
      end
    end

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: t('controller.successfully_updated', model: t('activerecord.models.profile')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.profile')) }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all
    @languages = Language.all
  end
end
