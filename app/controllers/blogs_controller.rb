class BlogsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:new, :create, :edit, :update, :destroy]

  DEFAULT_BLOG_ERROR_MESSAGE = "Error saving blog post. Make sure all fields are filled in and try again."

  def index
    last_blog = Blog.order('created_at').last
    redirect_to blog_path(last_blog)
  end

  def show
    @blog = Blog.find(params[:id])
    @blogs = Blog.all.order('created_at DESC')
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
        flash.now[:alert] = @blog.errors.full_messages&.first || DEFAULT_BLOG_ERROR_MESSAGE
        format.html { render :new }
      end
    end
  end

  def edit
    @blog = Blog.find(params[:id])
  end

  def update
    @blog = Blog.find(params[:id])
    respond_to do |format|
      if @blog.update(blog_params)
        format.html { redirect_to "/blogs", notice: "Blog was successfully updated." }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html do
          redirect_to "/blogs/#{@blog.id}/edit", alert: @blog.errors.full_messages&.first || DEFAULT_BLOG_ERROR_MESSAGE
        end
      end
    end
  end

  def destroy
    @blog = Blog.find(params[:id])
    if @blog.delete
      redirect_to blogs_path,
                  notice: 'Blog post successfully deleted.'
    else
      redirect_to blogs_path,
                  alert: 'Error deleting blog post.'
    end
  end

  private

  def blog_params
    params.require(:blog).permit(:title, :author, :body)
  end
end
