class UserMailer < ApplicationMailer
    
  def account_approved(user)
        @user = user
        mail(to: @user.email, subject: 'Your Registration has been Approved')
    end

    def account_denied(user)
        @user = user
        mail(to: @user.email, subject: 'Your Registration has been denied.')
    end
end
