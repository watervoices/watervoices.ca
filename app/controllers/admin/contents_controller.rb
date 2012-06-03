class Admin::ContentsController < Admin::BaseController

  def index
    @prefix = params[:prefix]
  end

  # AJAX
  def create
    @content = Content.new(params[:content])
    @content.save # FIXME: what about if save fails?
    render :text => m(@content.body)
  end

  # AJAX
  def update
    @content = Content.find params[:id]
    @content.update_attributes params[:content] # FIXME: what about if save fails?
    render :text => m(@content.body)
  end

  protected

  def nav_state
    @nav = :admin_contents
  end

end
