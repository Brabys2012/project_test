# frozen_string_literal: true

require_relative 'libs/files_operations'
require_relative 'libs/constants'

module BaseModules
  include Capybara::DSL
  include FilesOperations
  include Constants
end
