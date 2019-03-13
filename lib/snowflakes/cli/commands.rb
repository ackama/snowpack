# frozen_string_literal: true

require "hanami/cli"

module Snowflakes
  class CLI < Hanami::CLI
    def self.register(name, command = nil, aliases: [], &blk)
      Commands.register(name, command, aliases: aliases, &blk)
    end

    module Commands
      extend Hanami::CLI::Registry

      require_relative "commands/assets/compile"
      require_relative "commands/console"
      require_relative "commands/db/create"
      require_relative "commands/db/create_migration"
      require_relative "commands/db/drop"
      require_relative "commands/db/migrate"
      require_relative "commands/db/rollback"
      require_relative "commands/db/structure/dump"
      require_relative "commands/db/version"
    end
  end
end
