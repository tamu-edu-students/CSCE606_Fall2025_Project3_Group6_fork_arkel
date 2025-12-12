class Notification < ApplicationRecord
  def self.safe_column_names
    Array(column_names)
  rescue StandardError
    begin
      connection.schema_cache.columns_hash(table_name).keys
    rescue StandardError
      []
    end
  end

  def self.safe_has_column?(name)
    safe_column_names.include?(name.to_s)
  end

  # The DB schema in this app originally used `user_id` for recipient.
  # Support both `user_id` and `recipient_id` for compatibility across environments and during precompile before migrations.
  belongs_to :recipient, class_name: "User", foreign_key: (safe_has_column?("recipient_id") ? "recipient_id" : "user_id")
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  validates :notification_type, presence: true

  def self.unread
    if safe_has_column?("read_at")
      where(read_at: nil)
    elsif safe_has_column?("read")
      where(read: [ false, nil ])
    else
      where(nil)
    end
  end

  def self.read
    if safe_has_column?("read_at")
      where.not(read_at: nil)
    elsif safe_has_column?("read")
      where(read: true)
    else
      where("1 = 0")
    end
  end

  scope :recent, -> { order(created_at: :desc) }

  # Mark notification as read
  def mark_as_read!
    return if read?

    if has_attribute?(:read_at)
      update!(read_at: Time.current)
    elsif has_attribute?(:read)
      update!(read: true)
    else
      true
    end
  end

  # Mark notification as unread
  def mark_as_unread!
    return unless read?

    if has_attribute?(:read_at)
      update!(read_at: nil)
    elsif has_attribute?(:read)
      update!(read: false)
    else
      true
    end
  end

  def read?
    if has_attribute?(:read_at)
      read_at.present?
    elsif has_attribute?(:read)
      read == true
    else
      false
    end
  end

  def unread?
    !read?
  end

  # Mark notification as delivered (e.g. pushed to client)
  def mark_delivered!
    return if delivered?

    if has_attribute?(:delivered_at)
      update!(delivered_at: Time.current)
    else
      true
    end
  end

  def delivered?
    has_attribute?(:delivered_at) && delivered_at.present?
  end

  # Safe accessor for JSON payload
  def payload
    has_attribute?(:data) ? (data || {}) : {}
  end

  # Lightweight JSON representation used by controllers
  def as_json(options = {})
    allowed = %w[id actor_id notification_type body created_at]
    column_list = self.class.safe_column_names
    allowed << (column_list.include?("recipient_id") ? "recipient_id" : "user_id")
    allowed << "data" if column_list.include?("data")
    allowed << "read_at" if column_list.include?("read_at")
    allowed << "delivered_at" if column_list.include?("delivered_at")

    super({ only: allowed.map(&:to_sym) }.merge(options))
  end
end
