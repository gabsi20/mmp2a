# Displays different task pages
class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :authenticate, except: [:opentasks_as_json, :closedtasks_as_json, :archivedtasks_as_json]


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

  def opentasks_as_json
    if Apitoken.where(:token => params[:user]).first
      thisuser = Apitoken.where(:token => params[:user]).first.user
      @opentasks = thisuser.tasks.where(
        :id => thisuser.statuses.where(:status => 'open').map(&:task_id)
      ).order(:due)
      render :json => @opentasks
    else
      render :json => {}
    end
  end

  def closedtasks_as_json
    if Apitoken.where(:token => params[:user]).first
      thisuser = Apitoken.where(:token => params[:user]).first.user      
      @closedtasks = thisuser.tasks.where(
        :id => thisuser.statuses.where(:status => 'closed').map(&:task_id)
      ).order(:due)
      render :json => @closedtasks
    else
      render :json => {}
    end
  end

  def archivedtasks_as_json
    if Apitoken.where(:token => params[:user]).first
      thisuser = Apitoken.where(:token => params[:user]).first.user
      @archivedtasks = thisuser.tasks.where(
        :id => thisuser.statuses.where(:status => 'archived').map(&:task_id)
      ).order(:due)
      render :json => @archivedtasks
    else
      render :json => {}
    end
  end


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
