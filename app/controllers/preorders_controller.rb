class PreordersController < ApplicationController
  before_action :load_project, :only => [:new, :create, :success]

  def new
    @preorder = Preorder.new
  end

  def create
    @preorder = Preorder.new(preorder_parameters.merge(:address => request.remote_ip, :project => @project))

    if @preorder.valid? && verify_recaptcha
      ProcessPreorderService.new(@preorder).execute
      redirect_to success_preorders_path(:project => @project.name)
    else
      render :new
    end
  end

  def success
  end

  def confirm
    @preorder = Preorder.find_by(:confirmation_token => params[:token])
    
    if @preorder.present?
      @preorder.update(:confirmed => true)
    else
      render :invalid_token
    end
  end

  private

  def preorder_parameters
    params.require(:preorder).permit(:email, :name, :boards, :kits, :assembled)
  end

  def load_project
    @project = Project.find_by!(:name => params[:project])
    redirect_to disabled_project_path(@project.name) unless @project.enabled?
  end

  def verify_recaptcha
    return true if RecaptchaVerificationService.new('preorder', params['g-recaptcha-response'], request.remote_ip).execute
    
    @preorder.errors.add :base, 'CAPTCHA failed, please try again'
    false
  end
end