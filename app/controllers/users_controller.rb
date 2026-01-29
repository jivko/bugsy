class UsersController < ApplicationController
  before_action :require_admin, only: [:index, :new, :create, :destroy]
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update]

  def index
    @users = User.order(:name)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(new_user_params)

    if @user.save
      redirect_to users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_user_path(@user), notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == Current.user
      redirect_to users_path, alert: "You cannot delete yourself."
    else
      @user.destroy
      redirect_to users_path, notice: "User deleted successfully."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin
    redirect_to root_path, alert: "Not authorized" unless Current.user.admin?
  end

  def authorize_user
    unless Current.user.admin? || Current.user == @user
      redirect_to root_path, alert: "Not authorized"
    end
  end

  def new_user_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :role)
  end

  def user_params
    permitted = [:name, :email_address]
    permitted << :password << :password_confirmation if params[:user][:password].present?
    permitted << :role if Current.user.admin? && Current.user != @user

    params.require(:user).permit(permitted)
  end
end
