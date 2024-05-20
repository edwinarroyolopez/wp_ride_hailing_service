module Resources
    class Users < Grape::API
      resource :users do
        desc 'Login and get a token'
        params do
          requires :email, type: String, desc: 'Email of the user'
          requires :pass, type: String, desc: 'Password of the user'
        end
        post :login do
          user = find_user_by_email(params[:email])
  
          if user && BCrypt::Password.new(user[:pass]) == params[:pass]
            token = encode_token({ user_id: user[:user_id] })
            { token: "Bearer #{token}", user_id: user[:user_id] }
          else
            error!('Unauthorized', 401)
          end
        end
      end
    end
  end