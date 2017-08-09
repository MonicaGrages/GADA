class BlogsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:new, :create, :edit, :update, :destroy]

  def index
    @blogs = Blog.all.order('created_at DESC')
  end

  def show
    @blog = Blog.find(params[:id])
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(blog_params)
    respond_to do |format|
      if @blog.save
        format.html { redirect_to "/blogs", notice: "Blog was successfully created." }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new, alert: "Error creating blog. Make sure all required fields are correctly completed and try again." }
      end
    end
  end


  private
  def blog_params
    params.require(:blog)
      .permit(:title, :author, :content)
  end


end
