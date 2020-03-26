require 'rest-client'
require 'json'
# REQUEST STATUSES
#     0 - Pending 
#     1 - Complete and Notified 
#     2 - Deleted by User
#     3 - Complete but waiting notification

class RequestsController < ApplicationController

    before_action :authorize, :completed
    helper_method :getDaysLeft, :current_user, :format_id  
    include ActiveModel::Validations
    validates :title, presence: true
    validates :from_language, presence: true
    validates :to_language, presence: true
    validates :description, presence: true
    validates :deadline, presence: true
    validates :email, presence: true
    
    def index
        @name = session[:name]
        @role = session[:role]
        @status = params[:status] || [0, 1]
        @requests = Request.where(user_tarjimly_id: @userID, _status: @status).sort_by{ |r| r.created_at}.reverse!
        @total_count = Request.where(user_tarjimly_id: @userID, _status: [0,1]).count

        # New Request Modal
        response = RestClient.get( 'https://tarjim.ly/api/mobile/v1/public/all-languages')
        @languages = Array.new
        response.body.scan(/[^}]*}/).each do |pair|
            pair[0] = ""
            @languages.push JSON.parse(pair)['language']
        end
        @categories = ["Coronavirus", "Day To Day", "Legal", "Medical", "Housing", "Food", "Clothing", "Education", "Employment", "Immigration", "Asylum Interveiw", "Assylum Docs", "Other"]
        @format = params[:document_format] || "text"
        @request = Request.new
    end

    def show 
        rid = params[:request_id]
        @request = Request.find_by_id(rid)
        if @request.nil? || @request.user_tarjimly_id != @userID || @request._status == 2
            flash[:alert] = "You are not authorized to view this request!"
            redirect_to requests_url
            return
        end
        @claim = nil
        if @request._status == 1
            @request.claims.each do |c|
                if c._status == 1
                    @claim = c
                end
            end
        end
    end
    
    # Page Deprecated: New Request is part of index now
    def new
        response = RestClient.get( 'https://tarjim.ly/api/mobile/v1/public/all-languages')
        @languages = Array.new
        response.body.scan(/[^}]*}/).each do |pair|
            pair[0] = ""
            @languages.push JSON.parse(pair)['language']
        end
        @format = params[:document_format] || "text"
        @request = Request.new
    end
    
    def create
        flash[:success] = []
        params[:request]['to_language'].each do |to_lang|
            if to_lang.nil? || to_lang.empty?
                next
            end
  
            @request = Request.new(request_params)
            @request.to_language = to_lang
            @request.email = session[:email]
            @request.deadline = DateTime.strptime(params[:request]['deadline'], '%m/%d/%Y %I:%M %p')

            #TODO: should be a validation and include rest
            if @request.nil?
                flash[:alert] = "Uh Oh! There was an error creating your request." 
                redirect_to requests_url
                return
            end
            upload_format = params[:request][:format] || "text"
            if upload_format != "text"
                filename_string = @request.document_uploads.first.filename.to_s
                upload_format =  File.extname(filename_string)
                upload_format = upload_format[1..-1]
            end
            @request.document_format = upload_format
            @request.user_tarjimly_id = @userID
            @request.num_claims = 0 #TODO: Should be daault in db
            @request._status = 0  #TODO: Should be daault in db
            @request.deadline = @request.deadline.time.in_time_zone("UTC")
            @request.categories = @request.categories[1...]
            if !@request.save
                flash[:alert] = "Uh Oh! There was an error creating your request."
            end
            flash[:success] << "Successfully created your request '#{@request.title}''."
        end
       
       

        redirect_to requests_url
    end

    def delete 
        @request = Request.find(params[:request_id])
        if @request.user_tarjimly_id != @userID
            redirect_to requests_url
        elsif !@request.claims.nil? && @request.claims.present?
            @request._status = 2
            @request.save!
            @request.claims.each do |claim|
                claim._status = 3
                claim.save!
            end
        else 
            @request.destroy
        end 
        flash[:notice] = "Your request '#{@request.title}' has been deleted!"
        redirect_to requests_url
    end

    def getDaysLeft(request)
        request_time = request.deadline.time.in_time_zone(session[:time_zone])
        days_left = ( request_time - Time.now) /86400
        time_of_day = DateTime.parse(request_time.to_s).strftime("%l:%M %p")
        day_of_week = DateTime.parse(request_time.to_s).strftime("%A")
        day = DateTime.parse(request_time.to_s).strftime("%B %e")
        puts "DAYS LEFT: #{days_left}"
        if days_left >= 0 && days_left < 1
            return "Today, #{time_of_day}", false            
        elsif days_left >= 1 && days_left < 2
            return "Tomorrow, #{time_of_day}", false
        elsif days_left >= 2 && days_left < 7
            return "#{day_of_week}, #{time_of_day}", false
        elsif days_left < 0 && days_left >= -1
            return "Yesterday, #{time_of_day}", true
        elsif days_left < -1
            return "#{day}, #{time_of_day}", true
        else 
            return "#{day}, #{time_of_day}", false
        end
    end

    # def format_id(s)
    #     s_list = s.split(" ")
    #     returnString = ""
    #     s_list.each do |i|
    #         returnString += "_#{i.downcase}"
    #     end
    #     return returnString
    # end
    
    def authorize
        if @userID.present?
            return
        elsif session[:tarjimlyID].nil?
          flash[:alert] = "You must be logged into view this page"
          redirect_to '/auth' 
        elsif session[:role] == "Translator"
          flash[:alert] = "You must be authorized to view this page"
          redirect_to claims_path
        else 
          @userID = session[:tarjimlyID] 
        end
    end
    
    def completed
        @requests = Request.where(user_tarjimly_id: @userID, _status: 3)
       
        if @requests.present?
            flash[:success] = []
            @requests.each do |request|
                flash[:success] << "Your request #{view_context.link_to(request.title,  request_path(request_id: request.id))} has been translated!"
                request._status = 1
                request.save!
            end 
        else
            return 
        end 
    end

    private
    def request_params
        params.require(:request).permit(:from_language, :deadline, :document_text, :document_format, :title, :description,:form_type, to_language: [], categories: [], document_uploads: [])
    end
end
