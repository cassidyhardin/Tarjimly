require 'rest-client'
require 'json'

class AuthController < ApplicationController 

    def authenticate
        begin
            response = RestClient.post(
                'https://tarjim.ly/api/mobile/v1/auth/login', 
                {:email => params[:email], :password => params[:password]} )
        rescue RestClient::Exception
            flash[:info] = "Unsucessful login, please try again."
            redirect_to root_path
            return
        end
        begin
            user_response = RestClient.get(
                'https://tarjim.ly/api/mobile/v1/users/metadata', {:cookies => response.cookies})
        rescue RestClient::Exception => e
            redirect_to root_path, flash: {info: "Unable to authenticate Tarjimly User, please try again."}
            return
        end
        session[:name] = JSON.parse(user_response.body)['fb_first_name'] + " " +  JSON.parse(user_response.body)['fb_last_name']
        session[:email] = JSON.parse(user_response.body)['email']
        session[:role] = JSON.parse(user_response.body)['user_role']
        session[:tarjimlyID] = JSON.parse(response.body)["tarjimly_id"]
        session[:time_zone] = Ziptz.new.time_zone_name(JSON.parse(user_response.body)['ip_postal'])
        cookies[:key] = { :tarjimly_user => response.cookies, :expires => Time.now + 3600}
        if session[:role] == "Translator"
            redirect_to :controller => 'claims', :action => 'index' 
         else 
            redirect_to :controller => 'requests', :action => 'index' 
        end
    end 

    def authenticateFB
        # begin
        #     response = RestClient.get(
        #         'https://www.facebook.com/v6.0/dialog/oauth', 
        #         {:client_id => "223905042136103", :redirect_uri => 'http://localhost:3000/auth/facebook', :state => "{st=state123abc,ds=123456789}"} )
        # rescue RestClient::Exception
        #     flash[:info] = "Unsucessful login, please try again."
        #     redirect_to root_path
        #     return
        # end

        # begin
        #     user_response = RestClient.get(
        #         'https://tarjim.ly/api/mobile/v1/users/metadata', {:cookies => response.cookies})
        # rescue RestClient::Exception => e
        #     redirect_to root_path, flash: {info: "Unable to authenticate Tarjimly User, please try again."}
        #     return
        # end
        
        # session[:name] = JSON.parse(user_response.body)['fb_first_name'] + " " +  JSON.parse(user_response.body)['fb_last_name']
        # session[:email] = JSON.parse(user_response.body)['email']
        # session[:role] = JSON.parse(user_response.body)['user_role']
        # session[:tarjimlyID] = JSON.parse(response.body)["tarjimly_id"]
        # session[:time_zone] = Ziptz.new.time_zone_name(JSON.parse(user_response.body)['ip_postal'])
        # cookies[:key] = { :tarjimly_user => response.cookies, :expires => Time.now + 3600}
        # if session[:role] == "Translator"
        #     redirect_to :controller => 'claims', :action => 'index' 
        #  else 
        #     redirect_to :controller => 'requests', :action => 'index' 
        # end

    end

    def logout 
        session.clear
        cookies.clear
        redirect_to root_path
    end
end