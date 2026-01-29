class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authorize_project, only: [:edit, :update, :destroy]

  def index
    @projects = current_user_projects
  end

  def show
  end

  def new
    @project = Project.new
  end

  def create
    @project = Current.user.owned_projects.build(project_params)

    if @project.save
      @project.members << Current.user # Owner is also a member
      redirect_to @project, notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted successfully."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_project
    unless @project.editable_by?(Current.user)
      redirect_to projects_path, alert: "Not authorized"
    end
  end

  def current_user_projects
    scope = if Current.user.admin?
      Project.all
    else
      Project.where(owner: Current.user).or(Project.where(id: Current.user.project_ids))
    end
    scope.includes(:owner, :members).order(:name)
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
