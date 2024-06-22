class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ show update destroy ]
  before_action :authenticate_user!
  before_action :authorize_admin!, only: %i[ create update destroy ]


  # GET /categories
  def index
    @categories = Category.all

    # Sorting
    if params[:sort] == "creation"
      @categories = @categories.sort_by_creation
    elsif params[:sort] == "name"
      @categories = @categories.sort_by_name
    end

    @categories = @categories.map do |category|
      category.as_json.merge(category.category_image.attached? ? { category_image: rails_blob_url(category.category_image) } : {},
      workouts: category.workouts
      )
    end
  
    render json: @categories
  end

  # GET /categories/1
  def show
    render json: @category
  end

  # POST /categories
  def create
    @category = Category.new(category_params)

    if @category.save
      render json: @category, status: :created, location: @category
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      render json: @category
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    def authorize_admin!
      render json: { error: "Vous n'êtes pas autorisé à acceder à cette page." }, status: :unauthorized unless current_user.isAdmin?
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.require(:category).permit(:name, :category_image)
    end
end
