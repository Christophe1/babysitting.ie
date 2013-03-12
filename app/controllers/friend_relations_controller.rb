class FriendRelationsController < FrontEndController
  respond_to :html, :js
  before_filter :find_user_stats

  def create
    @user = User.find(params[:target_user_id])
    current_user.follow!(@user)    
    respond_with @user
  end

  def destroy
    relation = FriendRelation.find(params[:id])
    if relation.provider == SocialNetwork::FACEBOOK
      @user = User.find_by_external_user_id(relation.target_user_id)
    else
      @user = User.find(relation.target_user_id)
    end
    current_user.unfollow!(@user)
    respond_with @user
  end

  protected
    def find_user_stats
      @user_stats = User.find(params[:stats_user_id])
    end

end