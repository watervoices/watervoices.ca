class PagesController < ApplicationController

  def index
    @nav = :map
  end

  def search
  end

  def about
    # @todo see Etherpads
  end
  
  def mission
    @nav = :mission
  end
  
  def resources
    @nav = :resources    
  end
  
  def file_report
    @nav = :file_report
  end
  

end
