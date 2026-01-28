# frozen_string_literal: true

# Use UUIDv7 (time-ordered) instead of UUIDv4 (random) for better index performance
# Rails 8.1 uses this configuration
Rails.application.config.active_support.default_uuid_primary_key_type = :v7
