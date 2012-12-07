class PageTestController < ApplicationController

  def show_tabs
    @show_nav_bar = true
    render(:layout => 'submission', :action => 'page_test1')
  end

  def show_tab2
    @show_nav_bar = true
    render(:layout => 'submission', :action => 'page_test2')
  end

  def show_tab3
    @show_nav_bar = true
    render(:layout => 'submission', :action => 'page_test3')
  end

end
