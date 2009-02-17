class FavorsController < ApplicationController
  
  before_filter :logged_in, :except  => [ :index, :show, :search ]
  
  def index
    fetch_favors
  end
  
  def show
    @title = URI.unescape(params[:id])
    #OPTIMIZE Is here two separate BD calls, could these be done in one time?
    @favors = Favor.find(:all, :conditions => ["title = ? AND status = 'enabled'",@title.capitalize])
    fetch_favors
    
    
    render :action => :index
  end
  
  def search
    save_navi_state(['favors', 'search_favors'])
    if params[:q]
      query = params[:q]
      begin
        s = Ferret::Search::SortField.new(:title_sort, :reverse => false)
        favors = Favor.find_by_contents(query, {:sort => s}, {:conditions => "status <> 'disabled'"})
        @favors = favors.paginate :page => params[:page], :per_page => per_page
      end
    end
  end
  
  def create
    @favor = Favor.new(params[:favor])
    if @favor.save
      flash[:notice] = :favor_added  
      respond_to do |format|
        format.html { redirect_to @current_user }
        format.js  
      end
    else 
      flash[:error] = :favor_could_not_be_added 
      redirect_to @current_user
    end
  end
  
  def edit
    @editable_favor = Favor.find(params[:id])
    return unless must_be_current_user(@editable_favor.owner)
    @person = Person.find(params[:person_id])
    show_profile
    render :template => "people/show" 
  end
  
  def update
    @person = Person.find(params[:person_id])
    if params[:favor][:cancel]
      redirect_to person_path(@person) and return
    end  
    @favor = Favor.find(params[:id])
    return unless must_be_current_user(@favor.owner)
    if @favor.update_attribute(:title, params[:favor][:title])
      flash[:notice] = :favor_updated
    else 
      flash[:error] = :favor_could_not_be_updated
    end    
    redirect_to person_path(@person)
  end
  
  def destroy
    @favor = Favor.find(params[:id])
    return unless must_be_current_user(@favor.owner)
    @favor.disable
    flash[:notice] = :favor_removed
    redirect_to @current_user
  end
  
  def ask_for
    @person = Person.find(params[:person_id])
    @favor = Favor.find(params[:id])
    return unless must_not_be_current_user(@favor.owner, :cant_ask_for_own_favor)
  end
  
  def thank_for
    @favor = Favor.find(params[:id])
    return unless must_not_be_current_user(@favor.owner, :cant_thank_self_for_favor)
    @person = Person.find(params[:person_id])
    @kassi_event = KassiEvent.new
    @kassi_event.realizer_id = @person.id  
  end
  
  def mark_as_done
    @favor = Favor.find(params[:kassi_event][:eventable_id])
    return unless must_not_be_current_user(@favor.owner, :cant_thank_self_for_favor)
    create_kassi_event
    flash[:notice] = :thanks_for_favor_sent
    @person = Person.find(params[:person_id])    
    redirect_to @person
  end
  
  private
  
  def fetch_favors
    save_navi_state(['favors','browse_favors','',''])
    @letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ".split("")
    @favor_titles = Favor.find(:all, :conditions => "status <> 'disabled'", :select => "DISTINCT title", :order => 'title ASC').collect(&:title)
    #puts "FAVOR_TITLES ON: #{@favor_titles}"
  end
  
end
