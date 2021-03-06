# frozen_string_literal: true

require "hanami/cli"
require "snowpack/cli/application/command"
require "snowpack/console/context"

module Snowpack
  module CLI
    module Application
      module Commands
        class Console < Command
          REPL = begin
            require 'pry'
            Pry
          rescue LoadError
            require 'irb'
            IRB
          end

          desc "Open interactive console"

          def call(**)
            measure "#{prompt_prefix} booted in" do
              out.puts "=> starting #{prompt_prefix} console"
              application.boot!
            end

            start_repl
          end

          private

          def start_repl
            context = Snowpack::Console::Context.new(application)
            REPL.start(context, prompt: [proc { default_prompt }, proc { indented_prompt }])
          end

          def default_prompt
            "#{prompt_prefix}> "
          end

          def indented_prompt
            "#{prompt_prefix}* "
          end

          def prompt_prefix
            "#{inflector.underscore(application.config.name)}[#{application.env}]"
          end
        end

        register "console", Console
      end
    end
  end
end
