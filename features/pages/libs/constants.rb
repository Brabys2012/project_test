# frozen_string_literal: true

module Constants
  def self.download_dir
    @download_dir ||= File.join(Dir.pwd, 'features', 'tmp').freeze
  end
end
