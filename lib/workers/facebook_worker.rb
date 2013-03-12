class FacebookWorker
  @queue = :facebook

  class << self

    # Updates user facebook friends in background.
    #
    # @param fb_user_id [Fixnum] facebook user id.
    # @param access_token [String] facebook Graph API access token.
    #
    def update_friends(fb_user_id, access_token)
      Resque.enqueue(FacebookWorker, 'update_friends_bg', fb_user_id, access_token)
    end

    # Performs execution of background task for update facebook friends.
    #
    # @param fb_user_id [Fixnum] facebook user id.
    # @param access_token [String] facebook Graph API access token.
    #
    def update_friends_bg(fb_user_id, access_token)
      graph = RestGraph.new(:access_token => access_token)
      friends = graph.get("me/friends", { :limit => 0 }, :cache => false)
      if friends["data"].present?
        target_user_ids = friends["data"].map { |friend| friend["id"].to_i }
        FriendRelation.update_friends(fb_user_id, target_user_ids, SocialNetwork::FACEBOOK)
      end
    end

    # Performs resque task execution.
    #
    def perform(*args)
      ActiveRecord::Base.verify_active_connections!
      logger = Rails.resque_logger rescue nil
      Rails.logger = logger || Rails.logger
      method = args.shift
      self.send(method, *args)
    end
  end
end