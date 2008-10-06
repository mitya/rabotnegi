class SiteController < ApplicationController
  def map
    respond_to do |format|
      format.xml
    end
  end
end
