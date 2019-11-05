class NotificationMailer < ApplicationMailer
  default from: 'email@securityroots.com'
  default to: 'admin@securityroots.com'
  helper :application

  before_action :set_inline_attachments

  def digest
    @user = params[:user]
    @notifications = params[:notifications]
    @type = params[:type]

    set_user_avatar

    count = @notifications.count
    mail to: @user.email, subject: "You have #{count} unread #{'notification'.pluralize(count)}"
  end

  private

  def find_asset(name)
    Rails.application.assets.find_asset(name).pathname
  end

  def set_inline_attachments
    attachments.inline['profile'] = File.read(find_asset('profile.jpg'))
    attachments.inline['logo_small'] = File.read(find_asset('logo_small.png'))
    attachments.inline['DradisCE_full_small'] = File.read(find_asset('DradisCE_full_small.png'))
  end

  def set_user_avatar
    # The arguments are a noop here for CE-Pro parity.
    @avatar_url = attachments['profile'].url
  end
end