class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:mark_read]

  def index
    @notifications = current_user.notifications.recent

    respond_to do |format|
      format.html
      format.json { render json: @notifications.limit(50).map(&:as_json) }
    end
  end

  def mark_read
    @notification&.mark_as_read!
    head :no_content
  end

  def mark_all_read
    relation = current_user.notifications

    if Notification.column_names.include?('read_at')
      relation.unread.update_all(read_at: Time.current)
    elsif Notification.column_names.include?('read')
      relation.unread.update_all(read: true)
    end

    head :no_content
  end

  private

  def set_notification
    @notification = current_user.notifications.find_by(id: params[:id])
  end
end
