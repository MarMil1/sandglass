class UsersController < ApplicationController
    before_action :logged_in_user, only: [:edit, :update, :destroy]
    before_action :correct_user, only: [:edit, :update, :destroy]

    def show
        @user = User.find(params[:id])
        if current_user?(@user)
            @user
        else
            redirect_to errors_not_found_path
        end
    end


    def new
        @user = User.new
    end


    def create
        @user = User.new(user_params)
        if @user.save
            @user.send_activation_email
            flash[:info] = "Please check your email to activate your account."
            redirect_to root_url
        else
          render 'new'
        end
    end


    def edit
        @user = User.find(params[:id])
    end


    def update
        @user = User.find(params[:id])
        if @user.update(user_params)
            flash[:success] = "Profile updated"
            redirect_to @user
        else
          render 'edit'
        end
    end

    def show_user_articles
        @user = User.find(params[:user_id])
        @user_articles = Article.where(user_id: @user.id)
    end

    def add_favorite
        @favorite = current_user.favorites.build(article_id: params[:article_id])
        if @favorite.save
            flash[:success] = "Added to favorites."
            redirect_to request.referrer
        else 
            flash[:danger] = "Unable to add to favorites."
            redirect_to request.referrer
       end
    end

    def remove_favorite
        if current_user.favorite_articles.exists?(params[:article_id])
            current_user.favorite_articles.destroy(params[:article_id])
            flash[:success] = "Removed from favorites."
            redirect_to request.referrer
        else 
            flash[:danger] = "Unable to remove from favorites."
            redirect_to request.referrer
        end
    end

    def favorites
        @favorites = current_user.favorite_articles.order('created_at ASC')
        @favorite_articles = @favorites.where(id: Favorite.pluck(:article_id))
    end

    # TODO: delete profile image
    def delete_profile_image
        @user = User.find(params[:user_id])
        @image_id = @user.image.id.split('.')[0]

        if !@user.image.nil?
            result = Cloudinary::Uploader::destroy(@image_id)
            @user.update(image: nil)
            flash[:success] = "Profile image deleted."
        else 
            flash[:danger] = "Unable to delete profile image."
        end
        redirect_to request.referrer
    end

    # Delete user profile and all posted user articles
    def destroy
        @user = User.find(params[:id])
        @articles = Article.where(:user_id => params[:id])
        puts `This is user: #{@user}`
        if @user && @articles
            @articles.destroy_all
            @user.destroy
        else
            @user.destroy
        end

        flash[:success] = "User profile deleted"
        redirect_to articles_path
    end


    private 
    
        def user_params
            params.require(:user).permit(:username, :email, :password, :password_confirmation, :image)
        end
        

        # To confirm that it's the correct user
        def correct_user
            @user = User.find(params[:id])
            if !current_user?(@user) 
                redirect_to(articles_path)
                flash[:danger] = "Unauthorized action on user."
            end
        end


end
