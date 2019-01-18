# frozen_string_literal: true

require 'bundler'
Bundler.require :default
require 'sinatra/contrib/all'
require 'sinatra/reloader'

set :bind, '0.0.0.0'

helpers do
  def state_label(state)
    label = case state
            when /running/ then 'success'
            when /poweroff/ then 'secondary'
            else 'warning'
            end
    <<-TAG
    <span class="badge badge-#{label}">#{state}</span>
    TAG
  end
end

get '/' do
  @machines = Vagrant::Machine.all
  erb :index
end

module Vagrant
  class Machine
    ATTRIBUTES = %i[id name provider state directory]
    attr_reader *ATTRIBUTES

    def initialize(id:, name:, provider:, state:, directory:)
      @id = id
      @name = name
      @provider = provider
      @state = state
      @directory = directory
    end

    class << self
      def all
        result = []
        `vagrant global-status`.each_line.to_a.map(&:chop).each_with_index do |line, i|
          next if i < 2
          break if line == ' '

          result << new(Hash[ATTRIBUTES.zip(line.split(/\s+/))])
        end
        result
      end
    end
  end
end
