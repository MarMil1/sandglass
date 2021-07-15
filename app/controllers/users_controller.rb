class UsersController < ApplicationController

    def show
        @user = User.find(params[:id])
    end


    def new
        @user = User.new
    end


    def create
        @user = User.new(user_params)
        if @user.save
            log_in @user
            redirect_to @user
            flash[:success] = "Welcome to RoR Blog!"
        else
          render 'new'
        end
    end

    private 
    
        def user_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation)
        end


end
