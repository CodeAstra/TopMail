class EmailsController < ApplicationController
  require 'inbox'

  before_action :authenticate_user!

  def index
    @threads = Inbox.new(current_user).sort
  end
end
