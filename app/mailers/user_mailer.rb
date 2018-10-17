class UserMailer < ApplicationMailer
  default from: 'reddera123@gmail.com'
 
  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    #@password = password
    mail(to: @user.email, subject: 'Invitation to Join')
  end

  def payment_mail(current_user)
    @user = current_user


    @url  = 'http://example.com/login'
    #@password = password
    mail(to: @user.email, subject: 'PaymentSuccessfull')
  end
  def gift_card(details)
    @details=details
    mail(to:details.to_email, subject: 'Gift Card')
  end

  def complaint(details)

    @details=details
    mail(to:'bharat@reddera.com', subject: 'Complaint')
  end

  def inquiry(details)
    @details=details
    mail(to: 'bharat@reddera.com', subject: 'Inquiry')
  end
end
