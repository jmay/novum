class ProfilesController < ApplicationController
  respond_to :json

  # GET /profiles
  def index
    profiles = Profile.all
    render :json => {:profiles => profiles}
  end

  # GET /profiles/XXX
  def show
    profile = Profile[params[:id]]
    if profile
      logger.info "RESPONDING WITH #{profile.stripped.inspect}"
      respond_with profile.stripped
    else
      render :status => 404, :nothing => true
    end
  end

  # PUT /profiles/XXX (with payload)
  def update
    new_properties = params[:d]
    profile = Profile[params[:id]]
    profile.update_with(new_properties)

    respond_with(profile) do |format|
      format.json { render json: profile.stripped }
    end
  end

  # GET /profiles/XXX/YYY
  def attr
    profile = Profile[params[:id]]
    if !profile
      return render :status => 404, :nothing => true 
    end
    respond_with profile[params[:attr]]
  end

  # POST /profiles
  def create
    handle = params[:d][:handle]
    if Profile[handle]
      logger.info "PROFILE ALREADY EXISTS FOR [#{handle}]"
      return render :status => 500, :text => "PROFILE ALREADY EXISTS FOR [#{handle}]"
    end

    attributes = params[:d]
    profile = Profile.new
    attributes.each do |k,v|
      if v
        profile[k] = v
      end
    end
    profile.save

    redirect_to profile #respond_with profile.stripped
  end
end
