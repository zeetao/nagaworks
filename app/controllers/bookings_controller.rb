class BookingsController < ApplicationController

  def index
    # Turboframe search
    super_search_params = get_parameters_for_supersearch(params)
    
    if (super_search_params.present? and params[:target_dom].present?)
      @btu_outputs = supersearch_plus(BtuOutput, "btu_outputs.name", super_search_params)
      render turbo_stream: turbo_stream.replace(params[:target_dom], partial: "btu_outputs/btu_output_search_results", locals: {btu_outputs: @btu_outputs, params: super_search_params})
    end

    @btu_output_total = BtuOutput.count
  end
  
  # GET /btu_outputs/1 or /btu_outputs/1.json
  def show
  end

  # GET /btu_outputs/new
  def new
    @btu_output = BtuOutput.new
  end

  # GET /btu_outputs/1/edit
  def edit
  end

  # POST /btu_outputs or /btu_outputs.json
  def create
    @btu_output = BtuOutput.new(btu_output_params)

    respond_to do |format|
      if @btu_output.save
        format.html { redirect_to btu_output_url(@btu_output), notice: "BIO Transformation Unit was successfully created." }
        # format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {notice: "BIO Transformation Unit was successfully recorded."}) }
        # format.json { render :show, status: :created, location: @btu_output }
      else
        # format.html { redirect_to new_btu_output_path, status: :unprocessable_entity, alert: @btu_output.errors }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {alert: @btu_output.errors}) }
        # format.json { render json: @btu_output.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /btu_outputs/1 or /btu_outputs/1.json
  def update
    respond_to do |format|
      if @btu_output.update(btu_output_params)
        # format.html { redirect_to btu_output_url(@btu_output), notice: "BIO Transformation Unit was successfully updated." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {notice: "BIO Transformation Unit was successfully updated."}) }
        # format.json { render :show, status: :ok, location: @btu_output }
      else
        # format.html { redirect_to edit_btu_output_path(@btu_output), status: :unprocessable_entity, alert: @btu_output.errors }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("notices", partial: "partials/notices", locals: {alert: @btu_output.errors}) }
        # format.json { render json: @btu_output.errors, status: :unprocessable_entity }
      end
    end
  end


end
