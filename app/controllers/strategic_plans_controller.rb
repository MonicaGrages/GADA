class StrategicPlansController < ApplicationController
  before_action :authenticate_user!, :except => [:show]

  def show
    @strategic_plan = StrategicPlan.first
  end

  def edit
    @strategic_plan = StrategicPlan.first
  end

  def update
    strategic_plan = StrategicPlan.first

    strategic_plan.update(content: params.dig(:strategic_plan, :content))

    redirect_to(strategic_plan_path, notice: "Strategic plan successfully updated")
  end
end
