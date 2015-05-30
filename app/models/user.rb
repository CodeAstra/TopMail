class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.from_omniauth(access_token)
    data = access_token.info
    # debugger
    user = User.where(:email => data["email"]).first

    # Example data is:
    # <OmniAuth::AuthHash::InfoHash 
    #   email="bvsatyaram@gmail.com"
    #   first_name="BV"
    #   image="https://lh5.googleusercontent.com/-S3RkEI1mL34/AAAAAAAAAAI/AAAAAAAAFho/Vy-9Ay1qtUI/photo.jpg?sz=50"
    #   last_name="Satyaram"
    #   name="BV Satyaram"
    #   urls=#<OmniAuth::AuthHash Google="https://plus.google.com/+SatyaramBV">>
    unless user
      user = User.create(
        name: data.name,
        first_name: data.first_name,
        last_name: data.last_name,
        email: data["email"],
        password: Devise.friendly_token[0,20],
        image: data.image.split("?")[0],
        gplus_url: data.urls.first[1]
      )
    end
    user
  end
end
