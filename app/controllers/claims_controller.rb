# CLAIM STATUSES
#     0 - In Progress 
#     1 - Submitted
#     2 - Submitted by another Translator
#     3 - Deleted by the User
#     4 - Unclaimed

class ClaimsController < ApplicationController
  before_action :authorize
  helper_method :getDaysLeft, :isHighImpact, :isAlreadyClaimed, :current_translator

  def requests
    @claim = Claim.new
    claimed_ids = Claim.where(translator_tarjimly_id: @translatorID).pluck(:request_id)
    @no_pending_reqs =  Request.where.not(id: claimed_ids).empty?   
    if params.has_key?(:from_language)
      @requests = Request.where(:from_language => params[:from_language].capitalize, :to_language => params[:to_language].capitalize).where.not(id: claimed_ids, _status: 2)
    else
      @requests = Request.where.not(id: claimed_ids)
    end
    @requests = @requests.sort_by{ |r| [r.deadline, r.num_claims]}
  end

  def preview
    @claim = Claim.new
    @request = Request.find_by(:id => params[:request_id])
    @all_requests = Request.all
  end

  def create
    ActiveRecord::Base.transaction do
        Claim.create(translator_tarjimly_id: @translatorID, _status: 0, request_id: params[:request_id]) 
        req =  Request.find_by(id: params[:request_id])
        existing_claims = req.num_claims
        req.num_claims = existing_claims + 1
        req.save
        redirect_to claims_url
    end
  rescue ActiveRecord::RecordInvalid 
      flash[:notice] = "Uh Oh. Something went wrong, please try again."
      redirect_to view_requests_url
  end

  def index
    @name = session[:name]
    @role = session[:role]
    @status = params[:status] || [0,1]
    @claims = Claim.where({translator_tarjimly_id: @translatorID, _status: @status}).sort_by{ |c| [c._status, c.request.deadline]}
    @dismiss_claims = Claim.where({translator_tarjimly_id: @translatorID, _status: [2, 3]})
    @total_count = Claim.where({translator_tarjimly_id: @translatorID, _status: 1}).count
    if Claim.where({translator_tarjimly_id: @translatorID , _status: 3}).present?
      flash[:notice] = "Requests you claimed no longer require translation. You can dismiss them below!"
    end
    if Claim.where({translator_tarjimly_id: @translatorID, _status: 2}).present?
      flash[:notice] = "Requests you claimed have been submitted by another translator. You can dismiss them below!"
    end
  end

  def show
    @claim = Claim.find_by_id(params[:claim_id])
    if @claim.nil? || @claim.translator_tarjimly_id != @translatorID || !(@claim._status == 0 || @claim._status == 1)  
      flash[:alert] = "You are not authorized to view this claim."
      redirect_to claims_url
      return
    end
    @request = Request.find_by_id(@claim.request_id)
  end

  def delete
    @claim = Claim.find(params[:claim_id])
    if @claim.translator_tarjimly_id != @translatorID
      redirect_to claims_url
    end
    if @claim._status == 3
      @claim.destroy
      redirect_to claims_url
    else
      @claim.request.num_claims -= 1
      @claim.request.save!
      title = @claim.request.title
      @claim.destroy
      flash[:notice] = "You have successfully unclaimed the translation for #{title}!"
      redirect_to claims_url
    end
  end

  def complete
    ActiveRecord::Base.transaction do 
      claim = Claim.find_by(id: params[:claim_id])
      claim.translation_format = "text"
      claim.translation_text = params[:claim][:translation_text]
      claim._status = 1
      claim.save!
      req = claim.request
      req.claims.each do |c|
        if c.id.to_i != params[:claim_id].to_i
          c._status = 2
          c.save!
        end
      end
      req._status = 3
      req.save!
      RequestMailer.completed_request
      redirect_to claim_path(claim_id: params[:claim_id])
    end 
  rescue ActiveRecord::RecordInvalid 
      flash[:alert] = "Uh Oh. Submission unsuccessful, please try again."
  end

  def isHighImpact(from_lang, to_lang, req_id)
    high_impact_requests = Request.where(from_language: from_lang, to_language: to_lang, num_claims: 0).where.not(id: req_id)
    if Request.find_by_id(req_id).num_claims == 0 || high_impact_requests.empty?
      return true, nil
    else
      return false, high_impact_requests.first.id
    end
  end

  #TODO: Should be a validation also
  def isAlreadyClaimed(req_id)
    return !Claim.where({translator_tarjimly_id: @translatorID, request_id: req_id}).empty? 
  end

  def getDaysLeft(request)
    days_left = ((request.deadline.time.in_time_zone(session[:time_zone]) - request.created_at.time.in_time_zone(session[:time_zone])).to_i)/86400
    if days_left == -1
      return "1 day ago", true
    elsif days_left < 0
      return (-1*days_left).to_s + " days ago", true
    elsif days_left == 0
      return "Today", true
    elsif days_left == 1
      return "1 day", true
    else
      return days_left.to_s + " days", false
    end
  end

  def authorize
    if @translatorID.present?
      return
    elsif session[:tarjimlyID].nil?
      flash[:alert] = "You must be logged into view this page"
      redirect_to '/auth' 
    elsif session[:role] != "Translator"
      flash[:alert] = "You must be authorized to view this page"
      redirect_to requests_path
    else 
      @translatorID = session[:tarjimlyID] 
    end
  end
end