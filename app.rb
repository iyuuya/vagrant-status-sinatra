require 'bundler'
Bundler.require :default
require 'sinatra/contrib/all'
require 'sinatra/reloader'

helpers do
  def state_label(state)
    label = case state
            when /running/ then 'success'
            when /poweroff/ then 'default'
            else 'warning'
            end
    <<-TAG
    <span class="label label-#{label}">#{state}</span>
    TAG
  end
end

get '/' do
  @machines = Vagrant::Machine.all
  erb :index
end

module Vagrant
  class Machine
    ATTRIBUTES = %i(id name provider state directory)
    attr_reader *ATTRIBUTES

    def initialize(id: id, name: name, provider: provider, state: state, directory: directory)
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
          break if line == " "
          result << self.new(Hash[ATTRIBUTES.zip(line.split(/\s+/))])
        end
        result
      end
    end
  end
end
