module SessionsHelper

    # Logs in the user
    def log_in(user)
        session[:user_id] = user.id
    end

    # To remember a user in a persistent session
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # If given user is the current user, return true
    def current_user?(user)
        user == current_user
    end


    # If there is a logged in user, return it based on remembered token cookie
    def current_user
        if (user_id = session[:user_id])
          @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
          user = User.find_by(id: user_id)
          if user && user.authenticated?(:remember, cookies[:remember_token])
            log_in user
            @current_user = user
          end
        end
    end

    # If user logged in return true, else false
    def logged_in?
        !current_user.nil?
    end


    # To forget the persistent session
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end


    # Logs out the user
    def log_out
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end


    # Redirect to stored or default location
    def redirect_back_or(default)
        redirect_to (session[:forwarding_url] || default)
        session.delete(:forwarding_url)
    end


    # To store url that's trying to access
    def store_location
        session[:forwarding_url] = request.url if request.get?
    end


end
