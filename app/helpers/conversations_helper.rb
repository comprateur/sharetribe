module ConversationsHelper
  
  def get_message_title(listing)
    t("conversations.new.#{listing.category.name}_#{listing.listing_type}_message_title", :title => listing.title, :default => t("conversations.new.#{listing.listing_type}_message_title", :title => listing.title))
  end
  
  def transaction_proposal_form_title(listing)
    "#{listing.category.name}_#{Listing.opposite_type(listing.listing_type)}#{listing.share_type.present? ? '_' + @listing.share_type.name : ''}_message_form_title"
  end
  
  def icon_for(status)
    case status
    when "accepted"
      "ss-check"
    when "confirmed"
      "ss-check"
    when "rejected"
      "ss-delete"
    when "canceled"  
      "ss-delete"
    end
  end
  
  def path_for_status_link(status, conversation, current_user)
    case status
    when "accept"
      accept_person_message_path(:person_id => current_user.id, :id => conversation.id.to_s)
    when "confirm"
      confirm_person_message_path(:person_id => current_user.id, :id => conversation.id.to_s)
    when "reject"
      reject_person_message_path(:person_id => @current_user.id, :id => conversation.id.to_s)
    when "cancel"  
      cancel_person_message_path(:person_id => current_user.id, :id => conversation.id.to_s)
    end 
  end
  
end
