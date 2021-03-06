# frozen_string_literal: true

Dummy::Application.boot :persistence, namespace: true do |container|
  init do
    require "rom"
    register "config", ROM::Configuration.new(:sql, container[:settings].database_url)
  end

  start do
    register "rom", ROM.container(container["persistence.config"])
  end
end
