# Displays different task pages
class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, except: [:opentasks_as_json, :closedtasks_as_json, :archivedtasks_as_json, :api_toggle_task, :api_archive_task]
  skip_before_action :verify_authenticity_token, only: [:api_toggle_task, :api_archive_task]
  before_action :auth_mobile, only: [:opentasks_as_json, :closedtasks_as_json, :archivedtasks_as_json, :api_toggle_task, :api_archive_task]
  # GET /tasks
  # GET /tasks.json
  def index
    @opentasks = current_user.tasks.where(
      :id => current_user.statuses.where(:status => 'open').map(&:task_id)
    ).order(:due)
    @closedtasks = current_user.tasks.where(
      :id => current_user.statuses.where(:status => 'closed').map(&:task_id)
    ).order(:due)
    @calendars = Calendar.all
  end

  def authenticate
    if !current_user

      redirect_to root_path,
        :notice => 'You need to login before handling tasks.'
    end
  end

  # API-Tasks

  def auth_mobile
    if !Apitoken.where(:token => params[:user]).first
      render :json => {error: "User doesnt exist"}
    else
      @mobile_user = Apitoken.where(:token => params[:user]).first.user
    end
  end

  def opentasks_as_json
    tasks = @mobile_user.tasks.references(:statuses).where( statuses: { status: 'open' }).order(:due)
    status_tasks = []
    tasks.all.each do |task|
      status_tasks.push({
        task: task,
        status: @mobile_user.statuses.where(:task_id => task.id).first.status
      })
    end
    render :json => status_tasks
  end

  def closedtasks_as_json
    tasks = @mobile_user.tasks.references(:statuses).where( statuses: { status: 'closed' }).order(:due)
    status_tasks = []
    tasks.all.each do |task|
      status_tasks.push({
        task: task,
        status: @mobile_user.statuses.where(:task_id => task.id).first.status
      })
    end
    render :json => status_tasks
  end

  def archivedtasks_as_json
    tasks = @mobile_user.tasks.references(:statuses).where( statuses: { status: 'archived' }).order(:due)
    status_tasks = []
    tasks.all.each do |task|
      status_tasks.push({
        task: task,
        status: @mobile_user.statuses.where(:task_id => task.id).first.status
      })
    end
    render :json => status_tasks
  end

  def api_toggle_task
    # if params are set and apitoken exists
    if params[:task] && params[:user] && @mobile_user
      # if status with task exists
      if @mobile_user.statuses.where(:task_id => params[:task]).first
        this_status = @mobile_user.statuses.where(:task_id => params[:task]).first

        # toggle status
        if this_status.status == 'open'
          this_status.status = 'closed'          
        else
          this_status.status = 'open'
        end
        this_status.save
        render :json => {
          status: this_status.status
        }        
      else
        # task not found
        render :json => {
          error: "task not found"
        }
      end
    else
      # apitoken does not exist
      render :json => {
        error: "authentication failed"
      }
    end
  end

  def api_archive_task
    # if params are set and apitoken exists
    if params[:task] && params[:user] && @mobile_user
      # if status with task exists
      if @mobile_user.statuses.where(:task_id => params[:task]).first
        this_status = @mobile_user.statuses.where(:task_id => params[:task]).first

        # archive status
        this_status.status = 'archived'
        this_status.save
        render :json => {
          status: this_status.status
        }        
      else
        # task not found
        render :json => {
          error: "task not found"
        }
      end
    else
      # apitoken does not exist
      render :json => {
        error: "authentication failed"
      }
    end
  end

  def api_get_token
    if Apitoken.where(user_id: current_user.id).exists? 
      this_token = Apitoken.where(user_id: current_user.id).first.token
      render :json => {
        api_token: this_token
      }
    else
      render :json => {
        error: "no token set"
      }
    end
  end

  # End API-Tasks


  def archive
    @archivedtasks = current_user.tasks.where(
      :id => current_user.statuses.where(:status => 'archived').map(&:task_id)
    ).order(:due)
    @calendars = Calendar.all
  end

  def done
    @donetasks = current_user.tasks.where(
      :id => current_user.statuses.where(:status => 'closed').map(&:task_id)
    ).order(:due)
    @calendars = Calendar.all
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  def testmethod
    puts params
  end

  def taskdone
    @status = current_user.statuses.where(:task_id => params[:tid]).first
    @message = Task.toggle_status @status
    respond_to do |format|
      if @status.save
        format.html { redirect_to tasks_path, notice: @message}
      else
        format.html { redirect_to tasks_path, notice: 'Failure.'}
      end
    end
  end

  def taskarchive
    @status = current_user.statuses.where(:task_id => params[:tid]).first
    @status.status = 'archived'
    respond_to do |format|
      if @status.save
        format.html { redirect_to tasks_path,
                      notice: 'Task archived successfully.'}
      else
        format.html { redirect_to tasks_path, notice: 'Failure.'}
      end
    end
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task,
                      notice: 'Task was successfully created.' }
        format.json { render :show,
                      status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task,
                      notice: 'Task was successfully updated.' }
        format.json { render :show,
                      status: :ok,
                      location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url,
                    notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def task_params
      params.require(:task).permit(:description, :autor, :participants, :due)
    end
end
