class SupportRequestsController < ApplicationController
  before_filter :admin_required, :only => [:index, :edit, :destroy]
  before_filter :login_required, :except => [:active_requests]
  
  def index
    respond_to do |format|
      format.html { @requests = SupportRequest.all(:order => ["resolved"]) }
    end
  end
  
  def active_requests
    respond_to do |format|
      format.json do        
        @requests = SupportRequest.find_all_by_resolved(false)
        
        @requests.map! {|request| request.station_description }
        
        @requests = [] if SupportRequest.count(:conditions => {:resolved => false, :ip_address => request.remote_ip}) > 0
        
        render :json => @requests.join(" and ").to_json
      end
    end
  end

  def create
    @request = SupportRequest.new(params[:support_request])
    
    @request.ip_address = request.remote_ip
    @request.resolved   = false
    
    @request = nil unless @request.save
      
    respond_to do |format|
      format.js
    end
  end

  def edit
    @request = SupportRequest.find(params[:id])
  end

  def update
    @request = SupportRequest.find(params[:id])
    
    if params[:support_request]
      @request.update_attributes(params[:support_request])
    else
      @request.resolved = true
    
      @request.save
    end
    
    respond_to do |format|
      format.html { redirect_to support_requests_path }
      format.js
    end
  end

  def destroy
    @request = SupportRequest.find(params[:id])
    
    @request.destroy
    
    redirect_to :action => 'index'
  end

end