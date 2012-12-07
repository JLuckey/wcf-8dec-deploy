class UserObserver < ActiveRecord::Observer
#  def after_create(user)
#    UserNotifier.deliver_signup_notification(user)
#    puts('UserObserver - after_create fired!')
#  end

#  def after_save(user)
#    puts('UserObserver - after_save fired - 1!')
#    UserNotifier.deliver_activation(user) 		  if user.recently_activated?
#	 	 UserNotifier.deliver_forgot_password(user) if user.recently_forgot_password?
#    UserNotifier.deliver_reset_password(user)  if user.recently_reset_password?
#    puts('UserObserver - after_save fired - 2!')
#  end

end
