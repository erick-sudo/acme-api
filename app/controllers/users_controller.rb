class UsersController < ApplicationController
    def index
        render json: User.all
    end

    def count
        render json: { count: User.count }
    end

    def create
        render json: User.create!(user_params), status: :created
    end

    def show
        render json: find_user
    end

    def show_user_email
        render json: find_user_by_email
    end

    def update
        user = find_user
        user.update!(user_params)
        render json: user, status: :accepted
    end

    def destroy
        user = find_user
        user.destroy
        head :no_content
    end

    private

    def find_user
        User.find(params[:id])
    end

    def find_user_by_email
        User.find_by!(email: user_params[:email])
    end

    def user_params
        params.permit(
            :name,
            :email,
            :password,
            :id
        )
    end
end
