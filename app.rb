require 'bundler'
Bundler.require :default
require 'sinatra/contrib/all'

get '/' do
  @statuses = Vagrant.global_status
  erb :index
end

class Vagrant
  class << self
    def global_status
      `vagrant global-status`
    end
  end
end
