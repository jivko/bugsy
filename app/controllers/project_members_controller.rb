class ProjectMembersController < ApplicationController
  before_action :set_project
  before_action :authorize_owner

  def index
    @memberships = @project.project_memberships.includes(:user).order("users.name")
    @available_users = User.where.not(id: @project.member_ids).order(:name)
  end

  def create
    user = User.find_by(id: params[:user_id])

    if user.nil?
      redirect_to project_members_path(@project), alert: "User not found."
    elsif @project.members.include?(user)
      redirect_to project_members_path(@project), alert: "User is already a member."
    else
      @project.members << user
      redirect_to project_members_path(@project), notice: "#{user.display_name} added to project."
    end
  end

  def destroy
    membership = @project.project_memberships.find(params[:id])
    
    if membership.user == @project.owner
      redirect_to project_members_path(@project), alert: "Cannot remove the project owner."
    else
      membership.destroy
      redirect_to project_members_path(@project), notice: "Member removed."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def authorize_owner
    unless @project.editable_by?(Current.user)
      redirect_to @project, alert: "Not authorized"
    end
  end
end
