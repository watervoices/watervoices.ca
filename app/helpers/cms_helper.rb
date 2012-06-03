module CmsHelper

  # markdown-based content from DB
  def c(key, default='')
    m(Content.where(:key => key).first.try(:body) || default)
  end

  # plain content (no markdown expected / applied)
  def pc(key, default='')
    Content.where(:key => key).first.try(:body) || default
  end

  def editable_content(key, title, type=:text_area)
    c = Content.where(:key => key).first || Content.new(:key => key)
    render 'admin/contents/form', :content => c, :title => title, :type => type
  end

end
