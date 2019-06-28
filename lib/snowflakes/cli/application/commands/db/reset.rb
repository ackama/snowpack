# frozen_string_literal: true

require "snowflakes/cli/application/command"
require_relative "drop"
require_relative "create"
require_relative "migrate"

module Snowflakes
  module CLI
    module Application
      module Commands
        module DB
          class Reset < Command
            desc "Drop, create, and migrate database"

            def call(**)
              run_command Drop
              run_command Create
              run_command Migrate
            end
          end
        end

        register "db reset", Commands::DB::Reset
      end
    end
  end
end
