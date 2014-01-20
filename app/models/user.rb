class User < Owner
  # TODO Add :omniauthable
  devise :trackable, :omniauthable, :omniauth_providers => [:github]

  extend FriendlyId
  friendly_id :nickname, use: :finders

  has_many :scrapers, foreign_key: :owner_id

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = User.find_or_create_by(:provider => auth.provider, :uid => auth.uid)
    user.update_attributes(nickname: auth.info.nickname, name:auth.info.name,
      access_token: auth.credentials.token,
      gravatar_id: auth.extra.raw_info.gravatar_id,
      blog: auth.extra.raw_info.blog,
      company: auth.extra.raw_info.company, email:auth.info.email)
    user
  end

  def refresh_info_from_github!
    user = Octokit.user(nickname)
    update_attributes(name:user.name,
        # image: auth.info.image,
        gravatar_id: user.gravatar_id,
        blog: user.blog,
        company: user.company,
        email: user.email)
  end

  def gravatar_url(size = 440)
    "https://www.gravatar.com/avatar/#{gravatar_id}?r=x&s=#{size}"
  end

  def github_url
    "https://github.com/#{nickname}"
  end
end
